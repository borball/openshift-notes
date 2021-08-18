## SNO Bootstrap Process

### AI SaaS

#### General steps

- On AI SaaS portal [[1]](https://console.redhat.com/openshift/assisted-installer/clusters/~new), create cluster and input the required information like:
	- cluster name
	- base domain
	- pull secret

- There are some work around to customize more for your cluster if necessary:
	- Call assisted-service rest API: [[2]](https://github.com/openshift/assisted-service/blob/master/docs/user-guide/restful-api-guide.md)
	- Use command line tool: [[3]](https://github.com/karmab/assisted-installer-cli)
	
  We used the second way to:
  
   - Configure work load partitioning [[4]](https://github.com/openshift/enhancements/blob/master/enhancements/workload-partitioning/management-workload-partitioning.md#example-manifests)
   - Set static IP address [[5]](https://docs.openshift.com/container-platform/4.8/networking/k8s_nmstate/k8s-nmstate-updating-node-network-config.html#virt-example-nmstate-IP-management-static_k8s_nmstate-updating-node-network-config)
   

	Those customized information/manifests together with the cluster basic information will be used to generate the ignition file inside the discovery ISO.
	
- Generate the discovery ISO
- Download the ISO and boot the server

#### Cluster Info

After steps above, the cluster information is showing as below, 

```ini
kni@bzhai-hive ~ $ aicli info cluster sno-ai-test --full
Using https://api.openshift.com as base url
ams_subscription_id: 1wu1KWDbfnDjvuuKPn2VGckErQu
base_dns_domain: cloud.lab.eng.bos.redhat.com
cluster_network_cidr: 10.128.0.0/14
cluster_network_host_prefix: 23
connectivity_majority_groups: {"IPv4":[],"IPv6":[]}
controller_logs_collected_at: 0001-01-01 00:00:00+00:00
controller_logs_started_at: 0001-01-01 00:00:00+00:00
created_at: 2021-08-18 13:33:14.880000+00:00
email_domain: redhat.com
feature_usage: {"SNO":{"name":"SNO"}}
high_availability_mode: None
host_networks: []
hosts: []
href: /api/assisted-install/v1/clusters/0b9959f6-5db8-4787-ad6e-0bb876f8e649
hyperthreading: all
id: 0b9959f6-5db8-4787-ad6e-0bb876f8e649
image_info: {'ssh_public_key': '', 'size_bytes': 107884544, 'download_url': 'https://s3.us-east-1.amazonaws.com/assisted-installer/discovery-image-0b9959f6-5db8-4787-ad6e-0bb876f8e649.iso?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA52ZYGBOVI2P2TOEQ%2F20210818%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210818T133830Z&X-Amz-Expires=14400&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3Bfilename%3Ddiscovery-image-0b9959f6-5db8-4787-ad6e-0bb876f8e649.iso&X-Amz-Signature=5d86b9543f2461f18dfc92eb592916f8e592368df0d6a4d39e59cf44e00d2229', 'generator_version': None, 'created_at': datetime.datetime(2021, 8, 18, 13, 38, 27, 217000, tzinfo=tzlocal()), 'expires_at': datetime.datetime(2021, 8, 18, 17, 38, 27, 217000, tzinfo=tzlocal()), 'static_network_config': 'dns-resolver:\n  config:\n    server:\n    - 10.19.143.247\ninterfaces:\n- ethernet:\n    auto-negotiation: true\n    duplex: full\n    speed: 1000\n  ipv4:\n    address:\n    - ip: 10.19.142.219\n      prefix-length: 21\n    enabled: true\n  mac-address: 3c:ec:ef:1c:f1:b8\n  mtu: 1500\n  name: eno1\n  state: up\n  type: ethernet\nroutes:\n  config:\n  - destination: 10.19.136.0/21\n    next-hop-address: 10.19.143.254\n    next-hop-interface: eno1\n  - destination: 0.0.0.0/0\n    next-hop-address: 10.19.143.254\n    next-hop-interface: eno1\n    table-id: 254\nHHHHH3c:ec:ef:1c:f1:b8=eno1', 'type': 'minimal-iso'}
install_completed_at: 2000-01-01 00:00:00+00:00
install_config_overrides: {"networking": {"networkType": "OVNKubernetes"}}
install_started_at: 2000-01-01 00:00:00+00:00
kind: Cluster
monitored_operators: [{'cluster_id': '0b9959f6-5db8-4787-ad6e-0bb876f8e649', 'name': 'console', 'namespace': None, 'subscription_name': None, 'operator_type': 'builtin', 'properties': None, 'timeout_seconds': 3600, 'status': None, 'status_info': None, 'status_updated_at': datetime.datetime(1, 1, 1, 0, 0, tzinfo=tzlocal())}, {'cluster_id': '0b9959f6-5db8-4787-ad6e-0bb876f8e649', 'name': 'cvo', 'namespace': None, 'subscription_name': None, 'operator_type': 'builtin', 'properties': None, 'timeout_seconds': 3600, 'status': None, 'status_info': None, 'status_updated_at': datetime.datetime(1, 1, 1, 0, 0, tzinfo=tzlocal())}]
name: sno-ai-test
ocp_release_image: quay.io/openshift-release-dev/ocp-release:4.8.2-x86_64
openshift_version: 4.8.2
org_id: 11009103
platform: {'type': 'baremetal', 'vsphere': {'username': None, 'password': None, 'datacenter': None, 'v_center': None, 'cluster': None, 'default_datastore': None, 'network': None, 'folder': None}}
progress: {'total_percentage': None, 'preparing_for_installation_stage_percentage': None, 'installing_stage_percentage': None, 'finalizing_stage_percentage': None}
pull_secret_set: True
schedulable_masters: False
service_network_cidr: 172.30.0.0/16
status: pending-for-input
status_info: User input required
status_updated_at: 2021-08-18 13:33:24.049000+00:00
updated_at: 2021-08-18 13:38:27.218000+00:00
user_managed_networking: True
user_name: bzhai@redhat.com
validations_info: {"configuration":[{"id":"pull-secret-set","status":"success","message":"The pull secret is set."}],"hosts-data":[{"id":"all-hosts-are-ready-to-install","status":"success","message":"All hosts in the cluster are ready to install."},{"id":"sufficient-masters-count","status":"failure","message":"Single-node clusters must have a single master node and no workers."}],"network":[{"id":"api-vip-defined","status":"success","message":"The API virtual IP is not required: User Managed Networking"},{"id":"api-vip-valid","status":"success","message":"The API virtual IP is not required: User Managed Networking"},{"id":"cluster-cidr-defined","status":"success","message":"The Cluster Network CIDR is defined."},{"id":"dns-domain-defined","status":"success","message":"The base domain is defined."},{"id":"ingress-vip-defined","status":"success","message":"The Ingress virtual IP is not required: User Managed Networking"},{"id":"ingress-vip-valid","status":"success","message":"The Ingress virtual IP is not required: User Managed Networking"},{"id":"machine-cidr-defined","status":"pending","message":"Hosts have not been discovered yet"},{"id":"machine-cidr-equals-to-calculated-cidr","status":"success","message":"The Cluster Machine CIDR is not required: User Managed Networking"},{"id":"network-prefix-valid","status":"success","message":"The Cluster Network prefix is valid."},{"id":"network-type-valid","status":"success","message":"The cluster has a valid network type"},{"id":"no-cidrs-overlapping","status":"pending","message":"At least one of the CIDRs (Cluster Network, Service Network) is undefined."},{"id":"ntp-server-configured","status":"success","message":"No ntp problems found"},{"id":"service-cidr-defined","status":"success","message":"The Service Network CIDR is defined."}],"operators":[{"id":"cnv-requirements-satisfied","status":"success","message":"cnv is disabled"},{"id":"lso-requirements-satisfied","status":"success","message":"lso is disabled"},{"id":"ocs-requirements-satisfied","status":"success","message":"ocs is disabled"}]}
vip_dhcp_allocation: False
```
#### Bootstrap Process

- Ignition file inside the ISO (iso/images/ignition.img)
	
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
	          Environment=PULL_SECRET_TOKEN=b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K29jbV9hY2Nlc3NfNDdjYWRhMzI2Y2EwNGViM2FlNjJiZGFmYzAwZGI1YWU6RTk2MTNWVjhHU1VHRlpQQjhaTTg1NlRRUUJTTFBPWk9XUDhTUjdVVDE1V0E1TzM0VVRJUllDMDRKTUswTFNNOQ==
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


### Manual Deployment

