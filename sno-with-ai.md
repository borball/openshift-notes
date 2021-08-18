## SNO Installation with AI SaaS

### DHCP

Assume a DHCP server exists to have dynamic IP assignment for the SNO node. 

- Go to https://cloud.redhat.com/openshift/assisted-installer/clusters/~new, fill the cluster name and base domain.
- Select “Install single node OpenShift” and follow the wizard. 
- Click "Generate Discovery ISO", fill the SSH key.
- Downliad the ISO.
- Mount the ISO as a virtual CD/DVD media.
- Boot your server from the virtual CD/DVD media.
- Installation will start.
- In the next reboot, change your server to boot from the hard disk.
- Installation will continue.

### Static IP


