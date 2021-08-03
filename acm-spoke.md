## ACM Spoke Cluster Deployment

### Prerequisites

- OCP cluster shall be deployed.
- A storage solution shall be available, refer to [Local Storage](openshift-local-storage.md) to set up a local storage solution, at least a default storageclass shall be existing on the cluster.
 

### Hub Setup

- ClusterImageSet

	```yaml
	apiVersion: hive.openshift.io/v1
	kind: ClusterImageSet
	metadata:
	  name: openshift-v4.8.0
	  namespace: open-cluster-management
	spec:
	  releaseImage: quay.io/openshift-release-dev/ocp-release:4.8.3-x86_64
	
	```

- AssistedServiceConfig

	```yaml
	apiVersion: v1
	kind: ConfigMap
	metadata:
	  name: assisted-service-config
	  namespace: open-cluster-management
	  labels:
	    app: assisted-service
	data:
	  LOG_LEVEL: "debug"
	
	```
	
- Private Key

	```yaml
	apiVersion: v1
	kind: Secret
	metadata:
	  name: assisted-deployment-ssh-private-key
	  namespace: open-cluster-management
	stringData:
	  ssh-privatekey: |-
		-----BEGIN OPENSSH PRIVATE KEY-----
		...
		CSvD9QZe1MjTftAAAAIWtuaUBiemhhaS1oaXZlLmUyZS5ib3MucmVkaGF0LmNvbQE=
		-----END OPENSSH PRIVATE KEY-----
	type: Opaque
	
	```
- Pull Secret

	```yaml
	apiVersion: v1
	kind: Secret
	metadata:
	  name: assisted-deployment-pull-secret
	  namespace: open-cluster-management
	stringData:
	  .dockerconfigjson: '...'
	
	```
- AgentServiceConfig

	```yaml
	apiVersion: agent-install.openshift.io/v1beta1
	kind: AgentServiceConfig
	metadata:
	  name: agent
	  namespace: open-cluster-management
	  ### This is the annotation that injects modifications in the Assisted Service pod
	  annotations:
	    unsupported.agent-install.openshift.io/assisted-service-configmap: "assisted-service-config"
	###
	spec:
	  databaseStorage:
	    accessModes:
	      - ReadWriteOnce
	    resources:
	      requests:
	        storage: 40Gi
	  filesystemStorage:
	    accessModes:
	      - ReadWriteOnce
	    resources:
	      requests:
	        storage: 40Gi
	  osImages:
	    - openshiftVersion: "4.8"
	      version: ""
	      url: "https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.8/4.8.2/rhcos-4.8.2-x86_64-live.x86_64.iso"
	      rootFSUrl: "https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.8/4.8.2/rhcos-4.8.2-x86_64-live-rootfs.x86_64.img"
	
	```
	
- Verify all pods status

	```shell
	kni@bzhai-hive ~ $ oc get pods -n open-cluster-management
	NAME                                                              READY   STATUS      RESTARTS   AGE
	6a6f7e5a647744999e099bb075a55388dce32c3ef46deb0a550195e2f2c6s5z   0/1     Completed   0          62m
	acm-custom-registry-76bcc46bfc-dmdhj                              1/1     Running     0          62m
	application-chart-744e5-applicationui-6fbbfc9d69-gs2kx            1/1     Running     0          59m
	application-chart-744e5-applicationui-6fbbfc9d69-jnslr            1/1     Running     0          59m
	application-chart-744e5-consoleapi-7595b78f54-f27sx               1/1     Running     0          59m
	application-chart-744e5-consoleapi-7595b78f54-txt6p               1/1     Running     0          59m
	assisted-service-fd7d68774-8fk5x                                  2/2     Running     1          5m10s
	cluster-curator-controller-cb87b7bc9-2r945                        1/1     Running     0          59m
	cluster-curator-controller-cb87b7bc9-qh8lj                        1/1     Running     0          59m
	cluster-manager-5b87b57b45-48gh2                                  1/1     Running     0          61m
	cluster-manager-5b87b57b45-fzrqf                                  1/1     Running     0          61m
	cluster-manager-5b87b57b45-nv4tq                                  1/1     Running     0          61m
	clusterlifecycle-state-metrics-v2-865bdbdf87-hvpn5                1/1     Running     0          59m
	console-chart-52173-console-v2-6d7c48f8d7-69n2c                   1/1     Running     0          59m
	console-chart-52173-console-v2-6d7c48f8d7-hmpjh                   1/1     Running     0          59m
	discovery-operator-694fcfdfc5-rcgvw                               1/1     Running     0          59m
	grc-d378f-grcui-65586d594d-h9r8m                                  1/1     Running     0          59m
	grc-d378f-grcui-65586d594d-kr2m9                                  1/1     Running     0          59m
	grc-d378f-grcuiapi-d47fb7859-f5tw6                                1/1     Running     0          59m
	grc-d378f-grcuiapi-d47fb7859-mzwlx                                1/1     Running     0          59m
	grc-d378f-policy-propagator-5ff7566745-8ngss                      1/1     Running     0          59m
	grc-d378f-policy-propagator-5ff7566745-vg7pz                      1/1     Running     0          59m
	hive-operator-97b764dc8-94zf2                                     1/1     Running     0          61m
	infrastructure-operator-647bd65474-xt278                          1/1     Running     0          59m
	klusterlet-addon-controller-v2-54cbffc84-2fssm                    1/1     Running     0          59m
	klusterlet-addon-controller-v2-54cbffc84-b8pht                    1/1     Running     0          59m
	kui-web-terminal-85dfb984fb-vnvlw                                 1/1     Running     0          59m
	managedcluster-import-controller-v2-fff567794-24lgl               1/1     Running     0          59m
	managedcluster-import-controller-v2-fff567794-vj5rk               1/1     Running     0          59m
	management-ingress-b7f26-68dbbdc64f-42crk                         2/2     Running     0          59m
	management-ingress-b7f26-68dbbdc64f-wrbj8                         2/2     Running     0          59m
	multicluster-observability-operator-666f484599-8zgd5              1/1     Running     0          61m
	multicluster-operators-application-8547cc6dbd-fgg6g               4/4     Running     3          61m
	multicluster-operators-channel-5bc76c8f4f-7gjkb                   1/1     Running     1          61m
	multicluster-operators-hub-subscription-7fd9f5999d-78c9j          1/1     Running     0          61m
	multicluster-operators-standalone-subscription-5654f58f5c-thmdk   1/1     Running     0          61m
	multiclusterhub-operator-85c7d7c64-484hh                          1/1     Running     0          61m
	multiclusterhub-repo-cbf74ffff-dmnxl                              1/1     Running     0          60m
	ocm-controller-bd7f8b4d5-664dn                                    1/1     Running     0          60m
	ocm-controller-bd7f8b4d5-ctq7j                                    1/1     Running     0          60m
	ocm-proxyserver-86844cf496-92pv7                                  1/1     Running     0          60m
	ocm-proxyserver-86844cf496-gzg4j                                  1/1     Running     0          60m
	ocm-webhook-5456bfbdd7-6dzfn                                      1/1     Running     0          60m
	ocm-webhook-5456bfbdd7-ql7jh                                      1/1     Running     0          60m
	policyreport-719f8-insights-client-7798dc4955-x2g5x               1/1     Running     0          59m
	policyreport-719f8-metrics-57c7b8cdf5-492k2                       1/1     Running     0          59m
	provider-credential-controller-5fdffd99c4-xjrt4                   2/2     Running     0          59m
	search-operator-76d846675f-kqmsx                                  1/1     Running     0          59m
	search-prod-9b78b-search-aggregator-6b98c4d876-lc4qr              1/1     Running     0          59m
	search-prod-9b78b-search-api-56867698c-59zl4                      1/1     Running     0          59m
	search-prod-9b78b-search-api-56867698c-7hd4j                      1/1     Running     0          59m
	search-prod-9b78b-search-collector-79699d57b7-rq5n6               1/1     Running     0          59m
	search-redisgraph-0                                               1/1     Running     0          55m
	search-ui-77dc5cd9ff-886ns                                        1/1     Running     0          59m
	search-ui-77dc5cd9ff-shgnb                                        1/1     Running     0          59m
	submariner-addon-f86cb7b4f-mbpk6                                  1/1     Running     0          61m
	```
	
### Spoke Clusters
