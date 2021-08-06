## OCP virtual cluster deployment with kcli

- Install virtualization tools
	
	```shell
	sudo yum -y install libvirt libvirt-daemon-driver-qemu qemu-kvm
	systemctl enable --now libvirtd
	```

- Install kcl

	```shell
	curl https://raw.githubusercontent.com/karmab/kcli/master/install.sh | bash
	```

- Checkout repo kcli-openshift4-baremetal

	```shell
	git clone https://github.com/karmab/kcli-openshift4-baremetal.git
	```

- Prepare prameter file

	```shell
	cp lab.yml bzhai-lab.yml
	```
	Then edit bzhai-lab.yml based on your needs:
	
	```yaml
	lab: true
	provisioning_enable: false
	pool: default
	dualstack: false
	dualstack_cidr: 192.168.130.0/24
	disconnected: false
	virtual_masters: true
	virtual_workers: true
	launch_steps: true
	deploy_openshift: true
	version: stable
	tag: 4.8
	cluster: bzhai-hive-hub
	domain: e2e.bos.redhat.com
	openshift_image: registry.ci.openshift.org/ocp/release:4.9
	baremetal_cidr: 192.168.129.0/24
	baremetal_net: lab-net
	provisioning_net: lab-prov
	virtual_masters_memory: 16384
	virtual_masters_numcpus: 8
	virtual_workers_deploy: false
	virtual_workers_number: 3
	virtual_workers_memory: 16384
	virtual_workers_numcpus: 8
	api_ip: 192.168.129.253
	ingress_ip: 192.168.129.252
	ipmi_user: jimi
	ipmi_password: hendrix
	baremetal_ips:
	- 192.168.129.20
	- 192.168.129.21
	- 192.168.129.22
	- 192.168.129.23
	- 192.168.129.24
	- 192.168.129.25
	baremetal_macs:
	- aa:aa:aa:aa:bb:01
	- aa:aa:aa:aa:bb:02
	- aa:aa:aa:aa:bb:03
	- aa:aa:aa:aa:bb:04
	- aa:aa:aa:aa:bb:05
	- aa:aa:aa:aa:bb:06
	vmrules:
	 - lab-installer:
	     disks: [200]
	 - master.*:
	     numamode: preferred
	     numa:
	     - id: 0
	       vcpus: 0-3
	       memory: 8192
	     - id: 1
	       vcpus: 4-7
	       memory: 8192
	 - worker.*:
	     numamode: preferred
	     numa:
	     - id: 0
	       vcpus: 0-3
	       memory: 8192
	     - id: 1
	       vcpus: 4-7
	       memory: 8192
	     extra_disks:
	     - 50
	     - 50
	```

- Deploy OCP

	```shell
	kcli create plan --force -f kcli_plan.yml --paramfile bzhai-lab.yml bzhai-lab
	```

- Check installer logs during installation

	```shell
	root@bzhai-hive ~/github/kcli-openshift4-baremetal (master) $ kcli list vm
	+--------------------------------+--------+----------------+--------------------------------------------------------+-----------+---------+
	|              Name              | Status |      Ips       |                         Source                         |    Plan   | Profile |
	+--------------------------------+--------+----------------+--------------------------------------------------------+-----------+---------+
	| bzhai-hive-hub-gwfgr-bootstrap |   up   | 192.168.129.66 |                                                        |           |         |
	|    bzhai-hive-hub-installer    |   up   | 192.168.129.81 | CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2 | bzhai-lab |  kvirt  |
	|    bzhai-hive-hub-master-0     |   up   | 192.168.129.20 |                                                        | bzhai-lab |  kvirt  |
	|    bzhai-hive-hub-master-1     |   up   | 192.168.129.21 |                                                        | bzhai-lab |  kvirt  |
	|    bzhai-hive-hub-master-2     |   up   | 192.168.129.22 |                                                        | bzhai-lab |  kvirt  |
	|    bzhai-hive-hub-worker-0     |  down  | 192.168.129.23 |                                                        | bzhai-lab |  kvirt  |
	|    bzhai-hive-hub-worker-1     |  down  | 192.168.129.24 |                                                        | bzhai-lab |  kvirt  |
	|    bzhai-hive-hub-worker-2     |  down  | 192.168.129.25 |                                                        | bzhai-lab |  kvirt  |
	+--------------------------------+--------+----------------+--------------------------------------------------------+-----------+---------+
	
	root@bzhai-hive ~ $ kcli ssh root@bzhai-hive-hub-installer "journalctl -f"
	
	or ssh to installer node:
	
	root@bzhai-hive ~ $ kcli ssh root@bzhai-hive-hub-installer 
	Activate the web console with: systemctl enable --now cockpit.socket
	
	Last login: Fri Aug  6 14:04:17 2021 from 192.168.129.1
	```
	
- Check bootstrap logs during installation

	```shell
	root@bzhai-hive ~ $ k ssh core@bzhai-hive-hub-gwfgr-bootstrap "journalctl -f"
	-- Logs begin at Fri 2021-08-06 14:05:15 UTC. --
	Aug 06 14:24:17 localhost systemd[19824]: Listening on GnuPG network certificate management daemon.
	Aug 06 14:24:17 localhost systemd[19824]: Listening on GnuPG cryptographic agent and passphrase cache.
	Aug 06 14:24:17 localhost systemd[19824]: Listening on Podman API Socket.
	Aug 06 14:24:17 localhost systemd[19824]: Listening on GnuPG cryptographic agent and passphrase cache (access for web browsers).
	Aug 06 14:24:17 localhost systemd[19824]: Started Create User's Volatile Files and Directories.
	Aug 06 14:24:17 localhost systemd[19824]: Listening on D-Bus User Message Bus Socket.
	Aug 06 14:24:17 localhost systemd[19824]: Reached target Sockets.
	Aug 06 14:24:17 localhost systemd[19824]: Reached target Basic System.
	Aug 06 14:24:17 localhost systemd[1]: Started User Manager for UID 1000.
	Aug 06 14:24:17 localhost systemd[19824]: Starting Podman auto-update service...
	Aug 06 14:24:17 localhost kubelet.sh[2561]: I0806 14:24:17.864876    2612 kubelet_node_status.go:386] "Setting node annotation to enable volume controller attach/detach"
	Aug 06 14:24:17 localhost kubelet.sh[2561]: I0806 14:24:17.875576    2612 kubelet_node_status.go:581] "Recording event message for node" node="localhost" event="NodeHasSufficientMemory"
	Aug 06 14:24:17 localhost kubelet.sh[2561]: I0806 14:24:17.875612    2612 kubelet_node_status.go:581] "Recording event message for node" node="localhost" event="NodeHasNoDiskPressure"
	Aug 06 14:24:17 localhost kubelet.sh[2561]: I0806 14:24:17.875637    2612 kubelet_node_status.go:581] "Recording event message for node" node="localhost" event="NodeHasSufficientPID"
	Aug 06 14:24:18 localhost systemd[19824]: podman-auto-update.service: Succeeded.
	```
	
	```shell
	root@bzhai-hive ~ $ k ssh core@bzhai-hive-hub-gwfgr-bootstrap "sudo podman ps"
	CONTAINER ID  IMAGE                                                                                                                   COMMAND               CREATED         STATUS             PORTS   NAMES
	f5f0587edb3d  quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:7dfd3a287f6cb129680742eb30c0c8ee88b44d8ceebc81bbe0e6fae5de5d117b                        21 minutes ago  Up 22 minutes ago          mariadb
	1fe4af09aa92  quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:7dfd3a287f6cb129680742eb30c0c8ee88b44d8ceebc81bbe0e6fae5de5d117b                        21 minutes ago  Up 21 minutes ago          httpd
	b765e94e46cc  quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:c4178cb406be4805f0856ae7e8dceef8baa2743146a717be8d4372478dacc097  start --tear-down...  20 minutes ago  Up 20 minutes ago          cluster-bootstrap
	493fe910f2fe  quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:7dfd3a287f6cb129680742eb30c0c8ee88b44d8ceebc81bbe0e6fae5de5d117b                        17 minutes ago  Up 17 minutes ago          ironic-conductor
	a2f5079d3720  quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:21fadb7ff2b35389586077e2c42cf2334da795e6ee1d6eebd089ba46604e1e46                        17 minutes ago  Up 17 minutes ago          ironic-inspector
	62f26f38b51a  quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:7dfd3a287f6cb129680742eb30c0c8ee88b44d8ceebc81bbe0e6fae5de5d117b                        17 minutes ago  Up 17 minutes ago          ironic-api
	a01835c7098c  quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:7dfd3a287f6cb129680742eb30c0c8ee88b44d8ceebc81bbe0e6fae5de5d117b                        17 minutes ago  Up 17 minutes ago          ironic-deploy-ramdisk-logs
	1bfd6525b9e1  quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:21fadb7ff2b35389586077e2c42cf2334da795e6ee1d6eebd089ba46604e1e46                        17 minutes ago  Up 17 minutes ago          ironic-inspector-ramdisk-logs
	```
	
	```shell
	root@bzhai-hive ~ $ k ssh core@bzhai-hive-hub-gwfgr-bootstrap "sudo podman logs -f --tail 10 493fe910f2fe"
	2021-08-06 14:30:10.435 1 DEBUG ironic_lib.json_rpc.server [req-83927615-5bbc-4f57-8069-c1f5f80be8ff - - - - -] RPC heartbeat returned None _handle_requests /usr/lib/python3.6/site-packages/ironic_lib/json_rpc/server.py:294
	2021-08-06 14:30:10.435 1 INFO eventlet.wsgi.server [req-83927615-5bbc-4f57-8069-c1f5f80be8ff - - - - -] ::ffff:192.168.129.66 "POST / HTTP/1.1" status: 200  len: 211 time: 0.0146325
	2021-08-06 14:30:10.435 1 DEBUG ironic.conductor.task_manager [-] Upgrading shared lock on node c8105a0e-279d-4b2b-b6c4-cbc0adfb8a91 for heartbeat to an exclusive one (shared lock was held 0.00 seconds) upgrade_lock /usr/lib/python3.6/site-packages/ironic/conductor/task_manager.py:378
	2021-08-06 14:30:10.744 1 DEBUG ironic.conductor.task_manager [-] Node c8105a0e-279d-4b2b-b6c4-cbc0adfb8a91 successfully reserved for heartbeat (took 0.31 seconds) reserve_node /usr/lib/python3.6/site-packages/ironic/conductor/task_manager.py:350
	2021-08-06 14:30:10.744 1 DEBUG ironic.drivers.modules.agent_base [-] Heartbeat from node c8105a0e-279d-4b2b-b6c4-cbc0adfb8a91 heartbeat /usr/lib/python3.6/site-packages/ironic/drivers/modules/agent_base.py:641
	2021-08-06 14:30:12.278 1 DEBUG ironic.drivers.modules.agent_client [-] Fetching status of agent commands for node c8105a0e-279d-4b2b-b6c4-cbc0adfb8a91 get_commands_status /usr/lib/python3.6/site-packages/ironic/drivers/modules/agent_client.py:310
	2021-08-06 14:30:12.294 1 DEBUG ironic.drivers.modules.agent_client [-] Status of agent commands for node c8105a0e-279d-4b2b-b6c4-cbc0adfb8a91: get_clean_steps: result "{'clean_steps': {'GenericHardwareManager': [{'step': 'erase_devices', 'priority': 10, 'interface': 'deploy', 'reboot_requested': False, 'abortable': True}, {'step': 'erase_devices_metadata', 'priority': 99, 'interface': 'deploy', 'reboot_requested': False, 'abortable': True}, {'step': 'erase_pstore', 'priority': 0, 'interface': 'deploy', 'reboot_requested': False, 'abortable': True}, {'step': 'delete_configuration', 'priority': 0, 'interface': 'raid', 'reboot_requested': False, 'abortable': True}, {'step': 'create_configuration', 'priority': 0, 'interface': 'raid', 'reboot_requested': False, 'abortable': True}]}, 'hardware_manager_version': {'generic_hardware_manager': '1.1'}}", error "None"; execute_clean_step: result "{'clean_result': None, 'clean_step': {'step': 'erase_devices_metadata', 'priority': 10, 'interface': 'deploy', 'reboot_requested': False, 'abortable': True, 'requires_ramdisk': True}}", error "None"; collect_system_logs: result "{'system_logs': '<...>'}", error "None"; get_deploy_steps: result "{'deploy_steps': {'GenericHardwareManager': [{'step': 'erase_devices_metadata', 'priority': 0, 'interface': 'deploy', 'reboot_requested': False}, {'step': 'apply_configuration', 'priority': 0, 'interface': 'raid', 'reboot_requested': False, 'argsinfo': {'raid_config': {'description': 'The RAID configuration to apply.', 'required': True}, 'delete_existing': {'description': "Setting this to 'True' indicates to delete existing RAID configuration prior to creating the new configuration. Default value is 'True'.", 'required': False}}}, {'step': 'write_image', 'priority': 0, 'interface': 'deploy', 'reboot_requested': False}, {'step': 'inject_files', 'priority': 0, 'interface': 'deploy', 'reboot_requested': False, 'argsinfo': {'files': {'description': "Files to inject, a list of file structures with keys: 'path' (path to the file), 'partition' (partition specifier), 'content' (base64 encoded string), 'mode' (new file mode) and 'dirmode' (mode for the leaf directory, if created). Merged with the values from node.properties[inject_files].", 'required': False}, 'verify_ca': {'description': 'Whether to verify TLS certificates. Global agent options are used by default.', 'required': False}}}]}, 'hardware_manager_version': {'generic_hardware_manager': '1.1'}}", error "None"; execute_deploy_step: result "None", error "None" get_commands_status /usr/lib/python3.6/site-packages/ironic/drivers/modules/agent_client.py:342
	2021-08-06 14:30:12.295 1 DEBUG ironic.drivers.modules.agent_base [-] Deploy step still running for node c8105a0e-279d-4b2b-b6c4-cbc0adfb8a91: None _get_completed_command /usr/lib/python3.6/site-packages/ironic/drivers/modules/agent_base.py:267
	2021-08-06 14:30:12.295 1 DEBUG ironic.drivers.modules.agent_base [-] deploy command status for node c8105a0e-279d-4b2b-b6c4-cbc0adfb8a91 on step {'step': 'write_image', 'priority': 80, 'argsinfo': None, 'interface': 'deploy'}: None process_next_step /usr/lib/python3.6/site-packages/ironic/drivers/modules/agent_base.py:1124
	2021-08-06 14:30:12.604 1 DEBUG ironic.conductor.task_manager [-] Successfully released exclusive lock for heartbeat on node c8105a0e-279d-4b2b-b6c4-cbc0adfb8a91 (lock was held 1.86 sec) release_resources /usr/lib/python3.6/site-packages/ironic/conductor/task_manager.py:447
	```
	
	```shell
	root@bzhai-hive ~ $ k ssh core@bzhai-hive-hub-gwfgr-bootstrap "sudo podman logs -f --tail 10 a7ce85757a73"
	Skipped "openshift-kubevirt-infra-namespace.yaml" namespaces.v1./openshift-kubevirt-infra -n  as it already exists
	Skipped "secret-aggregator-client-signer.yaml" secrets.v1./aggregator-client-signer -n openshift-kube-apiserver-operator as it already exists
	Skipped "secret-bound-sa-token-signing-key.yaml" secrets.v1./next-bound-service-account-signing-key -n openshift-kube-apiserver-operator as it already exists
	Skipped "secret-control-plane-client-signer.yaml" secrets.v1./kube-control-plane-signer -n openshift-kube-apiserver-operator as it already exists
	Skipped "secret-csr-signer-signer.yaml" secrets.v1./csr-signer-signer -n openshift-kube-controller-manager-operator as it already exists
	Skipped "secret-initial-kube-controller-manager-service-account-private-key.yaml" secrets.v1./initial-service-account-private-key -n openshift-config as it already exists
	Skipped "secret-kube-apiserver-to-kubelet-signer.yaml" secrets.v1./kube-apiserver-to-kubelet-signer -n openshift-kube-apiserver-operator as it already exists
	Skipped "secret-loadbalancer-serving-signer.yaml" secrets.v1./loadbalancer-serving-signer -n openshift-kube-apiserver-operator as it already exists
	Skipped "secret-localhost-serving-signer.yaml" secrets.v1./localhost-serving-signer -n openshift-kube-apiserver-operator as it already exists
	Skipped "secret-service-network-serving-signer.yaml" secrets.v1./service-network-serving-signer -n openshift-kube-apiserver-operator as it already exists
	```
- oc

	```shell
	root@bzhai-hive ~ $ kcli ssh root@bzhai-hive-hub-installer 
	[root@bzhai-hive-hub-installer ~]# export KUBECONFIG=/root/ocp/auth/kubeconfig 
	[root@bzhai-hive-hub-installer ~]# 
	[root@bzhai-hive-hub-installer ~]# oc get nodes

	```
	
## Issues

- Interface ID was wrong when enabling provisioning network or NUMA
	
	```shell
	oc logs -f -n openshift-machine-api metal3-65c8d9b84b-clwdr -c metal3-static-ip-set
	+ /usr/sbin/ip address flush dev ens3
	Device “ens3” does not exist.
	``` 
	Looks like the interface id was not ens3, also due to NUMA introduced extra pci slot

	```xml
	<controller type='pci' index='1' model='pci-expander-bus'>
      <model name='pxb'/>
      <target busNr='20'>
        <node>0</node>
      </target>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </controller>
    <controller type='pci' index='2' model='pci-expander-bus'>
      <model name='pxb'/>
      <target busNr='40'>
        <node>1</node>
      </target>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </controller>
    <controller type='usb' index='0' model='piix3-uhci'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>
    <controller type='scsi' index='0' model='virtio-scsi'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </controller>
    <controller type='virtio-serial' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
    </controller>
    <interface type='network'>
      <mac address='aa:aa:aa:aa:aa:01'/>
      <source network='lab-prov'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </interface>
    <interface type='network'>
      <mac address='aa:aa:aa:aa:bb:01'/>
      <source network='lab-net'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
    </interface>
	```
	
- 