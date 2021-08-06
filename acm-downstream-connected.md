## ACM downstream deployment (Connected)

### Preparation

- Clone https://github.com/open-cluster-management/deploy.git to your local folder, we use open-cluster-management-deploy

	```shell
	cd /home/kni/github
	git clone https://github.com/open-cluster-management/deploy.git open-cluster-management-deploy
	```

- Send request to slace channel #forum-acm to get permission of repo quay.io/acm-d 

- Generate pull secret
	- Go to https://quay.io/user/tpouyer?tab=settings replacing tpouyer with your username
	- Click on Generate Encrypted Password
	- Enter your quay.io password
	- Select Kubernetes Secret from left-hand menu
	- Click on Download tpouyer-secret.yaml except tpouyer will be your username
	- Save secret file in the prereqs directory as pull-secret.yaml
	- Edit pull-secret.yaml file and change the name to multiclusterhub-operator-pull-secret

		```yaml
		apiVersion: v1
		kind: Secret
		metadata:
		  name: multiclusterhub-operator-pull-secret 
		data:
		  .dockerconfigjson: ==
		type: kubernetes.io/dockerconfigjson
		```

- Create icsp.yaml to mirror 'registry.redhat.io/rhacm2' to 'quay.io/acm-d' for snapshot version images 

	```yaml
	apiVersion: operator.openshift.io/v1alpha1
	kind: ImageContentSourcePolicy
	metadata:
	  name: rhacm-repo
	spec:
	  repositoryDigestMirrors:
	  - mirrors:
	    - quay.io:443/acm-d
	    source: registry.redhat.io/rhacm2
	  - mirrors:
	    - registry.redhat.io/openshift4/ose-oauth-proxy
	    source: registry.access.redhat.com/openshift4/ose-oauth-proxy
	```

- Apply it

	```shell
	oc apply -f icsp.yaml
	```

- Eedit the secret to add entry quay.io if not exists.

	```shell
	oc edit secret -n openshift-config pull-secret
	```

	```yaml
	{
	  "auths": {
	    "cloud.openshift.com": {
	      "auth": "==",
	      "email": "bzhai@redhat.com"
	    },
	    "quay.io": {
	      "auth": "==",
	      "email": "bzhai@redhat.com"
	    },
	    "registry.connect.redhat.com": {
	      "auth": "==",
	      "email": "bzhai@redhat.com"
	    },
	    "registry.redhat.io": {
	      "auth": "==",
	      "email": "bzhai@redhat.com"
	    },
	    "quay.io:443": {
	      "auth": "==",
	      "email": ""
	    }
	  }
	}
	```

### Install ACM downstream

- Edit snapshot.ver to set the default ACM ssnapshot version you want to deploy. i.g. v2.3.0-RC2

- Export environment variables

	```shell
	export KUBECONFIG=<kubeconfig path>
	export CUSTOM_REGISTRY_REPO=quay.io:443/acm-d
	export COMPOSITE_BUNDLE=true
	export DEBUG=true
	```
	
- Deploy ACM

	
	```shell
	kni@bzhai-hive ~/github/open-cluster-management-deploy (master) $ ./start.sh --watch
	* Testing connection
	* Using baseDomain: router-default.bzhai-hive-hub.e2e.bos.redhat.com
	* oc CLI Client Version: 4.7.20
	Find snapshot tags @ https://quay.io/repository/open-cluster-management/acm-custom-registry?tab=tags
	Enter SNAPSHOT TAG: (Press ENTER for default: v2.3.0-RC2)
	
	* Downstream: false   Release Version: v2.3.0
	* Composite Bundle: true   Image Registry (CUSTOM_REGISTRY_REPO): quay.io:443/acm-d
	* Using: v2.3.0-RC2
	
	* Applying SNAPSHOT to multiclusterhub-operator subscription
	* Applying CUSTOM_REGISTRY_REPO to multiclusterhub-operator subscription
	* Applying SUBSCRIPTION_CHANNEL to multiclusterhub-operator subscription
	* Applying MODE to multiclusterhub-operator subscription
	* Applying STARTING_CSV to multiclusterhub-operator-subscription (advanced-cluster-management.v2.3.0)
	* Applying multicluster-hub-cr values
	
	##### Creating the open-cluster-management namespace
	namespace/open-cluster-management created
	
	##### Applying prerequisites
	Warning: resource serviceaccounts/default is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
	serviceaccount/default configured
	secret/multiclusterhub-operator-pull-secret created
	
	##### Allow secrets time to propagate #####
	
	##### Applying acm-operator subscription #####
	service/acm-custom-registry created
	deployment.apps/acm-custom-registry created
	operatorgroup.operators.coreos.com/default created
	catalogsource.operators.coreos.com/acm-custom-registry created
	subscription.operators.coreos.com/acm-operator-subscription created
	
	#####
	Wait for multiclusterhub-operator to reach running state (4min).
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: Waiting
	* STATUS: multiclusterhub-operator-85c7d7c64-xq9fd                          0/1     ContainerCreating   0          0s
	* STATUS: multiclusterhub-operator-85c7d7c64-xq9fd                          0/1     ContainerCreating   0          3s
	* multiclusterhub-operator is running
	
	* Beginning deploy...
	* Applying the multiclusterhub-operator to install Red Hat Advanced Cluster Management for Kubernetes
	multiclusterhub.operator.open-cluster-management.io/multiclusterhub created
	
	#####
	Wait for multicluster-operators-application to reach running state (4min).
	* STATUS: multicluster-operators-application-8547cc6dbd-fzsln               0/4     Running     0          10s
	* STATUS: multicluster-operators-application-8547cc6dbd-fzsln               0/4     Running     0          13s
	* STATUS: multicluster-operators-application-8547cc6dbd-fzsln               0/4     Running     0          16s
	* STATUS: multicluster-operators-application-8547cc6dbd-fzsln               0/4     Running     0          20s
	* STATUS: multicluster-operators-application-8547cc6dbd-fzsln               0/4     Running     0          23s
	* STATUS: multicluster-operators-application-8547cc6dbd-fzsln               0/4     Running     0          26s
	* STATUS: multicluster-operators-application-8547cc6dbd-fzsln               0/4     Running     0          29s
	* multicluster-operators-application is running
	
	#####
	Waited 0/1500 seconds for MCH to reach Ready Status.  Current Status: Installing
	#####
	COMPONENT                       STATUS          TYPE                            REASON                        
	application-chart-sub           Unknown         Unknown                         No conditions available       
	assisted-service-sub            Unknown         Unknown                         No conditions available       
	cluster-lifecycle-sub           Unknown         Unknown                         No conditions available       
	cluster-manager-cr              Unknown         Unknown                         No conditions available       
	console-chart-sub               Unknown         Unknown                         No conditions available       
	discovery-operator-sub          Unknown         Unknown                         No conditions available       
	grc-sub                         Unknown         Unknown                         No conditions available       
	kui-web-terminal-sub            Unknown         Unknown                         No conditions available       
	local-cluster                   Unknown         Unknown                         No conditions available       
	management-ingress-sub          Unknown         Unknown                         No conditions available       
	multiclusterhub-repo            Unknown         Unknown                         No conditions available       
	ocm-controller                  Unknown         Unknown                         No conditions available       
	ocm-proxyserver                 Unknown         Unknown                         No conditions available       
	ocm-webhook                     Unknown         Unknown                         No conditions available       
	policyreport-sub                Unknown         Unknown                         No conditions available       
	search-prod-sub                 Unknown         Unknown                         No conditions available
	
	Waited 30/1500 seconds for MCH to reach Ready Status.  Current Status: Installing
	#####
	COMPONENT                       STATUS          TYPE                            REASON                        
	application-chart-sub           Unknown         Unknown                         No conditions available       
	assisted-service-sub            Unknown         Unknown                         No conditions available       
	cluster-lifecycle-sub           Unknown         Unknown                         No conditions available       
	cluster-manager-cr              Unknown         Unknown                         No conditions available       
	console-chart-sub               Unknown         Unknown                         No conditions available       
	discovery-operator-sub          Unknown         Unknown                         No conditions available       
	grc-sub                         Unknown         Unknown                         No conditions available       
	kui-web-terminal-sub            Unknown         Unknown                         No conditions available       
	local-cluster                   Unknown         Unknown                         No conditions available       
	management-ingress-sub          Unknown         Unknown                         No conditions available       
	multiclusterhub-repo            True            Available                       MinimumReplicasAvailable      
	ocm-controller                  Unknown         Unknown                         No conditions available       
	ocm-proxyserver                 Unknown         Unknown                         No conditions available       
	ocm-webhook                     False           Available                       MinimumReplicasUnavailable    
	policyreport-sub                Unknown         Unknown                         No conditions available       
	search-prod-sub                 Unknown         Unknown                         No conditions available       
	
	Waited 60/1500 seconds for MCH to reach Ready Status.  Current Status: Installing
	Detected ACM Console URL: https://multicloud-console.apps.bzhai-hive-hub.e2e.bos.redhat.com
	#####
	COMPONENT                       STATUS          TYPE                            REASON                        
	application-chart-sub           False           Available                       MinimumReplicasUnavailable    
	assisted-service-sub            Unknown         Unknown                         No conditions available       
	cluster-lifecycle-sub           Unknown         Unknown                         No conditions available       
	cluster-manager-cr              True            Applied                         ClusterManagerApplied         
	console-chart-sub               Unknown         Unknown                         No conditions available       
	discovery-operator-sub          Unknown         Unknown                         No conditions available       
	grc-sub                         Unknown         Unknown                         No conditions available       
	kui-web-terminal-sub            Unknown         Unknown                         No conditions available       
	local-cluster                   Unknown         Unknown                         No conditions available       
	management-ingress-sub          Unknown         Unknown                         No conditions available       
	multiclusterhub-repo            True            Available                       MinimumReplicasAvailable      
	ocm-controller                  True            Available                       MinimumReplicasAvailable      
	ocm-proxyserver                 False           Available                       MinimumReplicasUnavailable    
	ocm-webhook                     True            Available                       MinimumReplicasAvailable      
	policyreport-sub                Unknown         Unknown                         No conditions available       
	search-prod-sub                 Unknown         Unknown                         No conditions available       
	
	Waited 90/1500 seconds for MCH to reach Ready Status.  Current Status: Installing
	Detected ACM Console URL: https://multicloud-console.apps.bzhai-hive-hub.e2e.bos.redhat.com
	#####
	COMPONENT                       STATUS          TYPE                            REASON                        
	application-chart-sub           False           Available                       MinimumReplicasUnavailable    
	assisted-service-sub            False           Available                       MinimumReplicasUnavailable    
	cluster-lifecycle-sub           False           Available                       MinimumReplicasUnavailable    
	cluster-manager-cr              True            Applied                         ClusterManagerApplied         
	console-chart-sub               False           Available                       MinimumReplicasUnavailable    
	discovery-operator-sub          True            Deployed                        InstallSuccessful             
	grc-sub                         False           Available                       MinimumReplicasUnavailable    
	kui-web-terminal-sub            False           Available                       MinimumReplicasUnavailable    
	local-cluster                   Unknown         Unknown                         No conditions available       
	management-ingress-sub          False           Available                       MinimumReplicasUnavailable    
	multiclusterhub-repo            True            Available                       MinimumReplicasAvailable      
	ocm-controller                  True            Available                       MinimumReplicasAvailable      
	ocm-proxyserver                 True            Available                       MinimumReplicasAvailable      
	ocm-webhook                     True            Available                       MinimumReplicasAvailable      
	policyreport-sub                False           Available                       MinimumReplicasUnavailable    
	search-prod-sub                 False           Available                       MinimumReplicasUnavailable    
	
	Waited 120/1500 seconds for MCH to reach Ready Status.  Current Status: Installing
	Detected ACM Console URL: https://multicloud-console.apps.bzhai-hive-hub.e2e.bos.redhat.com
	#####
	COMPONENT                       STATUS          TYPE                            REASON                        
	application-chart-sub           False           Available                       MinimumReplicasUnavailable    
	assisted-service-sub            True            Deployed                        InstallSuccessful             
	cluster-lifecycle-sub           False           Available                       MinimumReplicasUnavailable    
	cluster-manager-cr              True            Applied                         ClusterManagerApplied         
	console-chart-sub               False           Available                       MinimumReplicasUnavailable    
	discovery-operator-sub          True            Deployed                        InstallSuccessful             
	grc-sub                         False           Available                       MinimumReplicasUnavailable    
	kui-web-terminal-sub            True            Deployed                        InstallSuccessful             
	local-cluster                   Unknown         Unknown                         No conditions available       
	management-ingress-sub          False           Available                       MinimumReplicasUnavailable    
	multiclusterhub-repo            True            Available                       MinimumReplicasAvailable      
	ocm-controller                  True            Available                       MinimumReplicasAvailable      
	ocm-proxyserver                 True            Available                       MinimumReplicasAvailable      
	ocm-webhook                     True            Available                       MinimumReplicasAvailable      
	policyreport-sub                False           Available                       MinimumReplicasUnavailable    
	search-prod-sub                 False           Available                       MinimumReplicasUnavailable    
	
	Waited 150/1500 seconds for MCH to reach Ready Status.  Current Status: Installing
	Detected ACM Console URL: https://multicloud-console.apps.bzhai-hive-hub.e2e.bos.redhat.com
	#####
	COMPONENT                       STATUS          TYPE                            REASON                        
	application-chart-sub           False           Available                       MinimumReplicasUnavailable    
	assisted-service-sub            True            Deployed                        InstallSuccessful             
	cluster-lifecycle-sub           True            Deployed                        InstallSuccessful             
	cluster-manager-cr              True            Applied                         ClusterManagerApplied         
	console-chart-sub               True            Deployed                        InstallSuccessful             
	discovery-operator-sub          True            Deployed                        InstallSuccessful             
	grc-sub                         True            Deployed                        InstallSuccessful             
	kui-web-terminal-sub            True            Deployed                        InstallSuccessful             
	local-cluster                   Unknown         Unknown                         No conditions available       
	management-ingress-sub          True            Progressing                     ReplicaSetUpdated             
	multiclusterhub-repo            True            Available                       MinimumReplicasAvailable      
	ocm-controller                  True            Available                       MinimumReplicasAvailable      
	ocm-proxyserver                 True            Available                       MinimumReplicasAvailable      
	ocm-webhook                     True            Available                       MinimumReplicasAvailable      
	policyreport-sub                False           Available                       MinimumReplicasUnavailable    
	search-prod-sub                 False           Available                       MinimumReplicasUnavailable    
	
	Waited 180/1500 seconds for MCH to reach Ready Status.  Current Status: Installing
	Detected ACM Console URL: https://multicloud-console.apps.bzhai-hive-hub.e2e.bos.redhat.com
	#####
	COMPONENT                       STATUS          TYPE                            REASON                        
	application-chart-sub           True            Deployed                        InstallSuccessful             
	assisted-service-sub            True            Deployed                        InstallSuccessful             
	cluster-lifecycle-sub           True            Deployed                        InstallSuccessful             
	cluster-manager-cr              True            Applied                         ClusterManagerApplied         
	console-chart-sub               True            Deployed                        InstallSuccessful             
	discovery-operator-sub          True            Deployed                        InstallSuccessful             
	grc-sub                         True            Deployed                        InstallSuccessful             
	kui-web-terminal-sub            True            Deployed                        InstallSuccessful             
	local-cluster                   Unknown         Unknown                         No conditions available       
	management-ingress-sub          True            Deployed                        InstallSuccessful             
	multiclusterhub-repo            True            Available                       MinimumReplicasAvailable      
	ocm-controller                  True            Available                       MinimumReplicasAvailable      
	ocm-proxyserver                 True            Available                       MinimumReplicasAvailable      
	ocm-webhook                     True            Available                       MinimumReplicasAvailable      
	policyreport-sub                True            Deployed                        InstallSuccessful             
	search-prod-sub                 False           Available                       MinimumReplicasUnavailable           
	
	Waited 210/1500 seconds for MCH to reach Ready Status.  Current Status: Installing
	Detected ACM Console URL: https://multicloud-console.apps.bzhai-hive-hub.e2e.bos.redhat.com
	#####
	COMPONENT                       STATUS          TYPE                            REASON                        
	application-chart-sub           True            Deployed                        InstallSuccessful             
	assisted-service-sub            True            Deployed                        InstallSuccessful             
	cluster-lifecycle-sub           True            Deployed                        InstallSuccessful             
	cluster-manager-cr              True            Applied                         ClusterManagerApplied         
	console-chart-sub               True            Deployed                        InstallSuccessful             
	discovery-operator-sub          True            Deployed                        InstallSuccessful             
	grc-sub                         True            Deployed                        InstallSuccessful             
	kui-web-terminal-sub            True            Deployed                        InstallSuccessful             
	local-cluster                   True            ManagedClusterImportSuccess     ManagedClusterImported        
	management-ingress-sub          True            Deployed                        InstallSuccessful             
	multiclusterhub-repo            True            Available                       MinimumReplicasAvailable      
	ocm-controller                  True            Available                       MinimumReplicasAvailable      
	ocm-proxyserver                 True            Available                       MinimumReplicasAvailable      
	ocm-webhook                     True            Available                       MinimumReplicasAvailable      
	policyreport-sub                True            Deployed                        InstallSuccessful             
	search-prod-sub                 True            Deployed                        InstallSuccessful 
	
	MCH reached Running status after 240 seconds.
	Detected ACM Console URL: https://multicloud-console.apps.bzhai-hive-hub.e2e.bos.redhat.com
	
	#####
	* Red Hat ACM URL: https://multicloud-console.apps.bzhai-hive-hub.e2e.bos.redhat.com
	#####
	Done!    
	```
	
- Verify the MCH annotation

	```shell
	oc annotate mch multiclusterhub mch-imageRepository='quay.io:443/acm-d'
	```
	
### ACM web conole

Open `https://multicloud-console.apps.<cluster_name>.<base_domain>`. 

 
### Enable FeatureGate AlphaAgentInstallStrategy 

```shell
oc patch hiveconfig hive --type merge -p '{"spec":{"targetNamespace":"hive","logLevel":"debug","featureGates":{"custom":{"enabled":["AlphaAgentInstallStrategy"]},"featureSet":"Custom"}}}'
```

