## Requirements

See requirements mentioned in this repo: https://github.com/borball/openshift-ansible-kvm. 

## Preparation

- Generate a pull secret on site https://console.redhat.com/openshift/install/metal/installer-provisioned 
- Clone repo: https://github.com/borball/openshift-ansible-kvm to your local
- Edit file vars/vm_setting.yml

	```yaml
	net:
	  domain: e2e.bos.redhat.com
	  subdomain: bzhai-hive-hub
	
	# Guet Settings
	#  Bootstrap VM
	bootstrap:
	  - name: bootstrap
	    ip: 172.16.0.100
	    mac: "01"
	#  Master VMs
	master:
	  - name: master-0
	    ip: 172.16.0.101
	    mac: "02"
	    etcd_id: 0
	  - name: master-1
	    ip: 172.16.0.102
	    mac: "03"
	    etcd_id: 1
	  - name: master-2
	    ip: 172.16.0.103
	    mac: "04"
	    etcd_id: 2
	#  Worker VMs
	worker:
	  - name: worker-0
	    ip: 172.16.0.104
	    mac: "05"
	  - name: worker-1
	    ip: 172.16.0.105
	    mac: "06"
	  - name: worker-2
	    ip: 172.16.0.106
	    mac: "07"
	      
	# Bootstrap VM
	spec_bootstrap:
	  cpu: 4
	  ram: 16384
	  disk: 128
	  disk_cache: unsafe
		
	# Master VMs
	spec_master:
	  num_master: 3
	  cpu: 4
	  ram: 18432
	  disk: 128
	  disk_cache: unsafe
		
	# Worker VMs
	spec_worker:
	  num_worker: 3
	  cpu: 8 
	  ram: 18432
	  disk: 128
	  disk_cache: unsafe
	```

- Create file vars/config.yaml

	```shell
	cd vars
	cp config.yml.sample config.yml
	
- Edit file config.yml to specify the settings

	```yaml
	kvm_host:
	  ip: 10.19.115.235
	  if: enp3s0f0
	  
	openshift:
	  dist: ocp
	  install_version: 4.8.2
	  coreos_version:  4.8.2
	  
	key:
	  pullsecret: '{}' 
	  sshkey: 'ssh-rsa ==== kni@bzhai-hive.e2e.bos.redhat.com'  
	```

## Deploy

Run ansible command to deploy it:

```shell
sudo ansible-playbook main.yml
```

You may need to run command below several times during the installation for the worker nodes:

```shell
for i in `oc get csr --no-headers | grep -i pending |  awk '{ print $1 }'`; do oc adm certificate approve $i; done
```

## Verification

```shell
kni@bzhai-hive ~/github/openshift-ansible-kvm (master) $ oc get nodes 
NAME       STATUS   ROLES    AGE    VERSION
master-0   Ready    master   172m   v1.21.1+051ac4f
master-1   Ready    master   172m   v1.21.1+051ac4f
master-2   Ready    master   172m   v1.21.1+051ac4f
worker-0   Ready    worker   117m   v1.21.1+051ac4f
worker-1   Ready    worker   117m   v1.21.1+051ac4f
worker-2   Ready    worker   117m   v1.21.1+051ac4f
kni@bzhai-hive ~/github/openshift-ansible-kvm (master) $ 
kni@bzhai-hive ~/github/openshift-ansible-kvm (master) $ 
kni@bzhai-hive ~/github/openshift-ansible-kvm (master) $ 
kni@bzhai-hive ~/github/openshift-ansible-kvm (master) $ 
kni@bzhai-hive ~/github/openshift-ansible-kvm (master) $ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE
authentication                             4.8.2     True        False         False      103m
baremetal                                  4.8.2     True        False         False      170m
cloud-credential                           4.8.2     True        False         False      172m
cluster-autoscaler                         4.8.2     True        False         False      170m
config-operator                            4.8.2     True        False         False      171m
console                                    4.8.2     True        False         False      56m
csi-snapshot-controller                    4.8.2     True        False         False      171m
dns                                        4.8.2     True        False         False      170m
etcd                                       4.8.2     True        False         False      48m
image-registry                             4.8.2     True        False         False      167m
ingress                                    4.8.2     True        False         False      116m
insights                                   4.8.2     True        False         False      164m
kube-apiserver                             4.8.2     True        False         False      169m
kube-controller-manager                    4.8.2     True        False         False      169m
kube-scheduler                             4.8.2     True        False         False      169m
kube-storage-version-migrator              4.8.2     True        False         False      171m
machine-api                                4.8.2     True        False         False      171m
machine-approver                           4.8.2     True        False         False      170m
machine-config                             4.8.2     True        False         False      170m
marketplace                                4.8.2     True        False         False      170m
monitoring                                 4.8.2     True        False         False      115m
network                                    4.8.2     True        False         False      171m
node-tuning                                4.8.2     True        False         False      170m
openshift-apiserver                        4.8.2     True        False         False      167m
openshift-controller-manager               4.8.2     True        False         False      170m
openshift-samples                          4.8.2     True        False         False      166m
operator-lifecycle-manager                 4.8.2     True        False         False      170m
operator-lifecycle-manager-catalog         4.8.2     True        False         False      171m
operator-lifecycle-manager-packageserver   4.8.2     True        False         False      167m
service-ca                                 4.8.2     True        False         False      171m
storage                                    4.8.2     True        False         False      171m
kni@bzhai-hive ~/github/openshift-ansible-kvm (master) $ 
kni@bzhai-hive ~/github/openshift-ansible-kvm (master) $ 
kni@bzhai-hive ~/github/openshift-ansible-kvm (master) $ oc whoami --show-console 
https://console-openshift-console.apps.bzhai-hive-hub.e2e.bos.redhat.com
```
