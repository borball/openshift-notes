## SNO Bootstrap Process

### AI SaaS

#### General steps

- On AI SaaS portal [[1]](https://console.redhat.com/openshift/assisted-installer/clusters/~new), create cluster and input the required information like:
	- cluster name
	- base domain
	- pull secret

- There are some work around to customize more for your cluster if necessary, the way works is to call the assisted-service API, either:
	- Call assisted-service REST API via curl: [[2]](https://github.com/openshift/assisted-service/blob/master/docs/user-guide/restful-api-guide.md)
	- Use command line tool: [[3]](https://github.com/karmab/assisted-installer-cli), which is a wrapper of the REST API
	
  We used the second way to:
  
   - Configure work load partitioning [[4]](https://github.com/openshift/enhancements/blob/master/enhancements/workload-partitioning/management-workload-partitioning.md#example-manifests)
     
     ```shell
     aicli create manifests --dir /workdir/ai-manifests/ <your cluster name>
     ```
     
   - Set static IP address [[5]](https://docs.openshift.com/container-platform/4.8/networking/k8s_nmstate/k8s-nmstate-updating-node-network-config.html#virt-example-nmstate-IP-management-static_k8s_nmstate-updating-node-network-config)
   
   		Example of static IP configuration:
   
	   ```yaml
	   kni@bzhai-hive ~/.aicli $ cat aicli-parameters.yaml 
		static_network_config:
		- interfaces:
		    - name: eno1
		      type: ethernet
		      state: up
		      ethernet:
		        auto-negotiation: true
		        duplex: full
		        speed: 1000
		      ipv4:
		        address:
		        - ip: 10.19.142.216
		          prefix-length: 21
		        enabled: true
		      mtu: 1500
		      mac-address: 3c:ec:ef:1c:f1:b8
		  dns-resolver:
		    config:
		      server:
		      - 10.19.143.247
		  routes:
		    config:
		    - destination: 10.19.136.0/21
		      next-hop-address: 10.19.143.254
		      next-hop-interface: eno1
	   ```
   
	   ```shell
	   aicli create iso -m --paramfile ./aicli-parameters.yaml <your cluster name>
	   ```
   - Check cluster info
   
   		```shell
   		aicli info cluster <your cluster name>
   		```

	Some of those customized information/manifests together with the cluster basic information will be used to generate the ignition file inside the discovery ISO.
	
- Generate the discovery ISO
- Download the ISO
- Mount the ISO as a virtual image on the server and boot the server from the virtual image.

#### Bootstrap Process

- CoreOS will boot as liveCD mode with a ignition file
- Sample ignition file looks like below:
	
	```yaml
	{
	  "ignition": {
	    "version": "3.1.0"
	  },
	  "passwd": {
	    "users": [
	      {"groups":["sudo"],"name":"core","passwordHash":"!","sshAuthorizedKeys":["ssh-rsa ..."]}
	    ]
	  },
	  "systemd": {
	    "units": [{
	      "name": "agent.service",
	      "enabled": true,
	      "contents": "[Service]
	          Type=simple
	          Restart=always
	          RestartSec=3
	          StartLimitInterval=0
	          Environment=HTTP_PROXY=
	          Environment=http_proxy=
	          Environment=HTTPS_PROXY=
	          Environment=https_proxy=
	          Environment=NO_PROXY=
	          Environment=no_proxy=
	          Environment=PULL_SECRET_TOKEN==
	          TimeoutStartSec=1800
	          ExecStartPre=/usr/local/bin/agent-fix-bz1964591 registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54
	          ExecStartPre=podman run --privileged --rm -v /usr/local/bin:/hostbin registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54 cp /usr/bin/agent /hostbin
	          ExecStart=/usr/local/bin/agent --url https://api.openshift.com --infra-env-id 92e89ca4-e642-4d4d-8747-bd799020ab32 --agent-version registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54 --insecure=false  
	          
	          [Unit]
	          Wants=network-online.target
	          After=network-online.target
	          
	          [Install]
	          WantedBy=multi-user.target"
	    },
	    {
	        "name": "selinux.service",
	        "enabled": true,
	        "contents": "[Service]
	          Type=oneshot
	          ExecStartPre=checkmodule -M -m -o /root/assisted.mod /root/assisted.te
	          ExecStartPre=semodule_package -o /root/assisted.pp -m /root/assisted.mod
	          ExecStart=semodule -i /root/assisted.pp
	          
	          [Install]
	          WantedBy=multi-user.target"
	    },
	    {
	        "name": "pre-network-manager-config.service",
	        "enabled": true,
	        "contents": "[Unit]
	          Description=Prepare network manager config content
	          Before=dracut-initqueue.service
	          After=dracut-cmdline.service
	          DefaultDependencies=no
	          [Service]
	          User=root
	          Type=oneshot
	          TimeoutSec=10
	          ExecStart=/bin/bash /usr/local/bin/pre-network-manager-config.sh
	          PrivateTmp=true
	          RemainAfterExit=no
	          [Install]
	          WantedBy=multi-user.target"
	    }
	    ]
	  },
	  "storage": {
	    "files": [{
	      "overwrite": true,
	      "path": "/usr/local/bin/agent-fix-bz1964591",
	      "mode": 755,
	      "user": {
	          "name": "root"
	      },
	      "contents": { "source": "
	          #!/usr/bin/sh
	
	          # This script is a workaround for bugzilla 1964591 where symlinks inside /var/lib/containers/ get
	          # corrupted under some circumstances.
	          #
	          # In order to let agent.service start correctly we are checking here whether the requested
	          # container image exists and in case "podman images" returns an error we try removing the faulty
	          # image.
	          #
	          # In such a scenario agent.service will detect the image is not present and pull it again. In case
	          # the image is present and can be detected correctly, no any action is required.
	
	          IMAGE=$(echo $1 | sed 's/:.*//')
	          podman images | grep $IMAGE || podman rmi --force $1 || true
	
	      " }
	    },
	    {
	      "overwrite": true,
	      "path": "/etc/motd",
	      "mode": 420,
	      "user": {
	          "name": "root"
	      },
	      "contents": { "source": "
	          **  **  **  **  **  **  **  **  **  **  **  **  **  **  **  **  **  ** **  **  **  **  **  **  **
	          This is a host being installed by the OpenShift Assisted Installer.
	          It will be installed from scratch during the installation.
	
	          The primary service is agent.service. To watch its status, run:
	          sudo journalctl -u agent.service
	
	          To view the agent log, run:
	          sudo journalctl TAG=agent
	          **  **  **  **  **  **  **  **  **  **  **  **  **  **  **  **  **  ** **  **  **  **  **  **  **
	        " }
	    },
	    {
	      "overwrite": true,
	      "path": "/etc/NetworkManager/conf.d/01-ipv6.conf",
	      "mode": 420,
	      "user": {
	          "name": "root"
	      },
	      "contents": { "source": "
	          [connection]
	          ipv6.dhcp-iaid=mac
	          ipv6.dhcp-duid=ll
	      " }
	    },
	    {
	        "overwrite": true,
	        "path": "/root/.docker/config.json",
	        "mode": 420,
	        "user": {
	            "name": "root"
	        },
	        "contents": { "source": "
	            {"auths":{"cloud.openshift.com":{"auth":"==","email":"bzhai@redhat.com"},"quay.io":{"auth":"==","email":"bzhai@redhat.com"},"registry.connect.redhat.com":{"auth":"==","email":"bzhai@redhat.com"},"registry.redhat.io":{"auth":"==","email":"bzhai@redhat.com"}}
	        " }
	    },
	    {
	        "overwrite": true,
	        "path": "/root/assisted.te",
	        "mode": 420,
	        "user": {
	            "name": "root"
	        },
	        "contents": { "source": "data:text/plain;base64,Cm1vZHVsZSBhc3Npc3RlZCAxLjA7CnJlcXVpcmUgewogICAgICAgIHR5cGUgY2hyb255ZF90OwogICAgICAgIHR5cGUgY29udGFpbmVyX2ZpbGVfdDsKICAgICAgICB0eXBlIHNwY190OwogICAgICAgIGNsYXNzIHVuaXhfZGdyYW1fc29ja2V0IHNlbmR0bzsKICAgICAgICBjbGFzcyBkaXIgc2VhcmNoOwogICAgICAgIGNsYXNzIHNvY2tfZmlsZSB3cml0ZTsKfQojPT09PT09PT09PT09PSBjaHJvbnlkX3QgPT09PT09PT09PT09PT0KYWxsb3cgY2hyb255ZF90IGNvbnRhaW5lcl9maWxlX3Q6ZGlyIHNlYXJjaDsKYWxsb3cgY2hyb255ZF90IGNvbnRhaW5lcl9maWxlX3Q6c29ja19maWxlIHdyaXRlOwphbGxvdyBjaHJvbnlkX3Qgc3BjX3Q6dW5peF9kZ3JhbV9zb2NrZXQgc2VuZHRvOwo=" }
	    },
	    {
	        "path": "/usr/local/bin/pre-network-manager-config.sh",
	        "mode": 493,
	        "overwrite": true,
	        "user": {
	            "name": "root"
	        },
	        "contents": { "source": "
	            #!/bin/bash
	            # The directory that contains nmconnection files of all nodes
	            NMCONNECTIONS_DIR=/etc/assisted/network
	            MAC_NIC_MAPPING_FILE=mac_interface.ini
	
	            if [ ! -d "$NMCONNECTIONS_DIR" ]
	            then
	              exit 0
	            fi
	
	            # A map of host mac addresses to interface names
	            declare -A host_macs_to_hw_iface
	
	            # The directory that contains nmconnection files for the current host
	            host_dir=""
	
	            # The mapping file of the current host
	            mapping_file=""
	
	            # A nic-to-mac map created from the mapping file associated with the host
	            declare -A logical_nic_mac_map
	
	            # Find destination directory based on ISO mode
	            if [[ -f /etc/initrd-release ]]; then
	              ETC_NETWORK_MANAGER="/run/NetworkManager/system-connections"
	            else
	              ETC_NETWORK_MANAGER="/etc/NetworkManager/system-connections"
	            fi
	
	            # remove default connection file create by NM(nm-initrd-generator). This is a WA until
	            # NM is back to supporting priority between nmconnections
	            rm -f ${ETC_NETWORK_MANAGER}/*
	
	            # Create a map of host mac addresses to their network interfaces
	            function map_host_macs_to_interfaces() {
	              SYS_CLASS_NET_DIR='/sys/class/net'
	              for nic in $( ls $SYS_CLASS_NET_DIR )
	              do
	                mac=$(cat $SYS_CLASS_NET_DIR/$nic/address | tr '[:lower:]' '[:upper:]')
	                host_macs_to_hw_iface[$mac]=$nic
	              done
	            }
	
	            function find_host_directory_by_mac_address() {
	              for d in $(ls -d ${NMCONNECTIONS_DIR}/host*)
	              do
	                mapping_file="${d}/${MAC_NIC_MAPPING_FILE}"
	                if [ ! -f $mapping_file ]
	                then
	                  echo "Mapping file '$mapping_file' is missing. Skipping on directory '$d'"
	                  continue
	                fi
	
	                # check if mapping file contains mac-address that exists on the current host
	                for mac_address in $(cat $mapping_file | cut -d= -f1 | tr '[:lower:]' '[:upper:]')
	                do
	                  if [[ ! -z "${host_macs_to_hw_iface[${mac_address}]:-}" ]]
	                  then
	                    host_dir=$(mktemp -d)
	                    cp ${d}/* $host_dir
	                    return
	                  fi
	                done
	              done
	
	              if [ -z "$host_dir" ]
	              then
	                echo "None of host directories are a match for the current host"
	                exit 0
	              fi
	            }
	
	            function set_logical_nic_mac_mapping() {
	              # initialize logical_nic_mac_map with mapping file entries
	              readarray -t lines < "${mapping_file}"
	              for line in "${lines[@]}"
	              do
	                mac=${line%%=*}
	                nic=${line#*=}
	                logical_nic_mac_map[$nic]=${mac^^}
	              done
	            }
	
	            # Replace logical interface name in nmconnection files with the interface name from the mapping file
	            # of host's directory. Replacement is done based on mac-address matching
	            function update_interface_names_by_mapping_file() {
	
	              # iterate over host's nmconnection files and replace logical interface name with host's nic name
	              for nmconn_file in $(ls -1 ${host_dir}/*.nmconnection)
	              do
	                # iterate over mapping to find nmconnection files with logical interface name
	                for nic in "${!logical_nic_mac_map[@]}"
	                do
	                  mac=${logical_nic_mac_map[$nic]}
	
	                  # the pattern should match '=eth0' (interface name) or '=eth0.' (for vlan devices)
	                  if grep -q -e "=$nic$" -e "=$nic\." "$nmconn_file"
	                  then
	                    # get host interface name
	                    host_iface=${host_macs_to_hw_iface[$mac]}
	                    if [ -z "$host_iface" ]
	                    then
	                      echo "Mapping file contains MAC Address '$mac' (for logical interface name '$nic') that doesn't exist on the host"
	                      continue
	                    fi
	
	                    # replace logical interface name with host interface name
	                    sed -i -e "s/=$nic$/=$host_iface/g" -e "s/=$nic\./=$host_iface\./g" $nmconn_file
	                  fi
	                done
	              done
	            }
	
	            function copy_nmconnection_files_to_nm_config_dir() {
	              for nmconn_file in $(ls -1 ${host_dir}/*.nmconnection)
	              do
	                # rename nmconnection files based on the actual interface name
	                filename=$(basename $nmconn_file)
	                prefix="${filename%%.*}"
	                extension="${filename#*.}"
	                if [ ! -z "${logical_nic_mac_map[$prefix]}" ]
	                then
	                  dir_path=$(dirname $nmconn_file)
	                  mac_address=${logical_nic_mac_map[$prefix]}
	                  host_iface=${host_macs_to_hw_iface[$mac_address]}
	                  if [ ! -z "$host_iface" ]
	                  then
	                    mv $nmconn_file "${dir_path}/${host_iface}.${extension}"
	                  fi
	                fi
	              done
	
	              cp ${host_dir}/*.nmconnection ${ETC_NETWORK_MANAGER}/
	            }
	
	            map_host_macs_to_interfaces
	            find_host_directory_by_mac_address
	            set_logical_nic_mac_mapping
	            update_interface_names_by_mapping_file
	            copy_nmconnection_files_to_nm_config_dir
	
	        
	        "}
	    },
	    {
	      "path": "/etc/assisted/network/host0/eno1.nmconnection",
	      "mode": 384,
	      "overwrite": true,
	      "user": {
	        "name": "root"
	      },
	      "contents": { "source": "
	          [connection]
	          id=eno1
	          uuid=871d1b2d-0776-40a9-b02e-cfd83d07fca8
	          type=ethernet
	          interface-name=eno1
	          permissions=
	          autoconnect=true
	          autoconnect-priority=1
	
	          [ethernet]
	          auto-negotiate=true
	          cloned-mac-address=3C:EC:EF:1C:F1:12
	          mac-address-blacklist=
	          mtu=1500
	
	          [ipv4]
	          address1=10.19.142.218/21
	          dhcp-client-id=mac
	          dns=10.19.143.247;
	          dns-priority=40
	          dns-search=
	          method=manual
	          route1=10.19.136.0/21,10.19.143.254
	          route1_options=table=254
	          route2=0.0.0.0/0,10.19.143.254
	          route2_options=table=254
	
	          [ipv6]
	          addr-gen-mode=eui64
	          dhcp-duid=ll
	          dhcp-iaid=mac
	          dns-search=
	          method=disabled
	
	          [proxy]
	
	
	      "}
	    },
	    {
	      "path": "/etc/assisted/network/host0/mac_interface.ini",
	      "mode": 384,
	      "overwrite": true,
	      "user": {
	        "name": "root"
	      },
	      "contents": { "source": "3c:ec:ef:1c:f1:12=eno1"}
		    }]
		  }
		}
	```	

- systemd

   Following services will be started automatically after the system booted from the ISO, at this stage CoreOS is running in RAM with liveCD mode.
   - selinux.service
	- pre-network-manager-config.service
	- agent.service

	pre-network-manager-config.service will configure the ststic IP.
		
- agent.service

	The agenet.service runs as an agent to communicate with assisted service API to get following instructions one by one to bootstrap the cluster. 
	Sample logs for the whole process: [sno-ai-agent.log](sno-ai-agent.log)
	Following are some of the important steps and its commands:
	
	- inventory
	
	```shell
	cp /etc/mtab /root/mtab && podman run --privileged --net=host --rm --quiet \
	-v /var/log:/var/log -v /run/udev:/run/udev -v /dev/disk:/dev/disk \
	-v /run/systemd/journal/socket:/run/systemd/journal/socket \
	-v /var/log:/host/var/log:ro -v /proc/meminfo:/host/proc/meminfo:ro \
	-v /sys/kernel/mm/hugepages:/host/sys/kernel/mm/hugepages:ro \
	-v /proc/cpuinfo:/host/proc/cpuinfo:ro -v /root/mtab:/host/etc/mtab:ro \
	-v /sys/block:/host/sys/block:ro -v /sys/devices:/host/sys/devices:ro \
	-v /sys/bus:/host/sys/bus:ro -v /sys/class:/host/sys/class:ro \
	-v /run/udev:/host/run/udev:ro -v /dev/disk:/host/dev/disk:ro \
	registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54 inventory
	```
	- domain-resolution
	
	```shell
	podman run --privileged --net=host --rm --quiet -v /var/log:/var/log \
	-v /run/systemd/journal/socket:/run/systemd/journal/socket \
	registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54 \
	domain_resolution -request 
	{"domains":[
		{"domain_name":"api.sno-ai-test.cloud.lab.eng.bos.redhat.com"}, \
		{"domain_name":"api-int.sno-ai-test.cloud.lab.eng.bos.redhat.com"}, \
		{"domain_name":"console-openshift-console.apps.sno-ai-test.cloud.lab.eng.bos.redhat.com"}
	]}
	```
	- free-network-addresses
	
	```shell
	 podman ps --format '{{.Names}}' | grep -q '^free_addresses_scanner$' \
	 || 
	 podman run --privileged --net=host --rm --quiet --name free_addresses_scanner \
	  -v /var/log:/var/log -v /run/systemd/journal/socket:/run/systemd/journal/socket \
	  registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54 \
	  free_addresses '[\"10.19.136.0/21\"]']
	```
	- ntp-synchronizer

	```shell
	podman run --privileged --net=host --rm -v /var/log:/var/log \
	-v /run/systemd/journal/socket:/run/systemd/journal/socket \
	-v /var/run/chrony:/var/run/chrony \
	registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54 \
	ntp_synchronizer {\"ntp_source\":\"\"}
	```
	
	Once the steps above completed, the AI SaaS UI will display the host/cluster information, select the network detected and start the installation, then the agent will get insttructions below:
	
	- container-image-availability
	
	```shell
	podman ps --format '{{.Names}}' | grep -q '^container_image_availability$' 
	|| 
	podman run --privileged --net=host --rm --quiet --pid=host \
	--name container_image_availability -v /var/log:/var/log \
	-v /run/systemd/journal/socket:/run/systemd/journal/socket \
	registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54 \
	container_image_availability \
	--request \
	  '{
	  "images":
		["quay.io/openshift-release-dev/ocp-release:4.8.2-x86_64",\
		  "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:216598b8db43a3d009a2635d3fc7abf8d3578c5e4525879952336579906338bb",\
		  "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:68bb88201fbf54c8c9709f224d2daaada8e7420f339e5c54d0628914c4401ebb", \
		  "registry.redhat.io/rhai-tech-preview/assisted-installer-rhel8:v1.0.0-81" \
		],
	  "timeout":960
	 }'
	```
	- installation-disk-speed-check
	
	```shell
	
	id=`podman ps --quiet --filter \"name=disk_performance\"` ; test ! -z \"$id\" 
	|| timeout 480.000000 podman run --privileged --rm --quiet -v /dev:/dev:rw \
	-v /var/log:/var/log -v /run/systemd/journal/socket:/run/systemd/journal/socket \
	--name disk_performance \
	registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54 \
	disk_speed_check 
	'{\"path\":\"/dev/disk/by-id/wwn-0x600304801dd989032809c2b0088dd308\"}'
	
	```
	- install

	```shell
	dd if=/dev/zero of=/dev/disk/by-id/wwn-0x600304801dd989032809c2b0088dd308 bs=512 count=1 ; \
	podman run --privileged \
	--pid=host --net=host --name=assisted-installer \
	--volume /dev:/dev:rw \
	--volume /opt:/opt:rw \
	--volume /var/log:/var/log:rw \
	--volume /run/systemd/journal/socket:/run/systemd/journal/socket \
	--env=PULL_SECRET_TOKEN \
		registry.redhat.io/rhai-tech-preview/assisted-installer-rhel8:v1.0.0-81 \
	--role bootstrap \
	--cluster-id 865d38c2-335e-4353-9c75-cc8f2f03c527 \
	--host-id d97f6435-7934-fd67-8741-3ab09a398792 \
	--boot-device /dev/disk/by-id/wwn-0x600304801dd989032809c2b0088dd308 \
	--url https://api.openshift.com --openshift-version 4.8.2 \
	--high-availability-mode None \
	--mco-image quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:216598b8db43a3d009a2635d3fc7abf8d3578c5e4525879952336579906338bb \
	--controller-image registry.redhat.io/rhai-tech-preview/assisted-installer-reporter-rhel8:v1.0.0-82 \
	--agent-image registry.redhat.io/rhai-tech-preview/assisted-installer-agent-rhel8:v1.0.0-54 \
	--must-gather-image '{
		"cnv":"registry.redhat.io/container-native-virtualization/cnv-must-gather-rhel8:v2.6.5", \
		"lso":"registry.redhat.io/openshift4/ose-local-storage-mustgather-rhel8", \
		"ocp":"quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:68bb88201fbf54c8c9709f224d2daaada8e7420f339e5c54d0628914c4401ebb", \
		"ocs":"registry.redhat.io/ocs4/ocs-must-gather-rhel8"}' \
	--check-cluster-version \
	--installer-args '[\"--append-karg\",\"ip=eno1:dhcp\"]
	
	```

After this step, the assisted-installer-rhel8 container above will bootstrap the openshift cluster. 

### Manual Deployment


### Reference

- [1]: https://console.redhat.com/openshift/assisted-installer/clusters/~new
- [2]: https://github.com/openshift/assisted-service/blob/master/docs/user-guide/restful-api-guide.md
- [3]: https://github.com/karmab/assisted-installer-cli
- [4]: https://github.com/openshift/enhancements/blob/master/enhancements/workload-partitioning/management-workload-partitioning.md#example-manifests
- [5]: https://docs.openshift.com/container-platform/4.8/networking/k8s_nmstate/k8s-nmstate-updating-node-network-config.html#virt-example-nmstate-IP-management-static_k8s_nmstate-updating-node-network-config

