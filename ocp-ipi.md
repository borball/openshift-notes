## OCP virtual cluster deployment with kcli

```shell

git clone https://github.com/borball/ocp-baremetal-ipi.git
cd ocp-baremetal-ipi
./setup.sh
```
A helper VM will be created on the host, you will be sshing to the helper node:

```shell
cd ocp4-installer
./install.sh
```

After 1.5 hours a cluster will be created:

```
# oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.8.5     True        False         9h      Cluster version is 4.8.5

# oc get nodes
NAME                 STATUS   ROLES    AGE   VERSION
openshift-master-0   Ready    master   11h   v1.21.1+9807387
openshift-master-1   Ready    master   11h   v1.21.1+9807387
openshift-master-2   Ready    master   11h   v1.21.1+9807387
openshift-worker-0   Ready    worker   10h   v1.21.1+9807387
openshift-worker-1   Ready    worker   10h   v1.21.1+9807387
openshift-worker-2   Ready    worker   10h   v1.21.1+9807387
```
