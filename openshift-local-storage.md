## OpenShift LocalStorage Operator

### Prerequisites

A OCP cluster shall have been deployed, and the worker nodes shall have extra disks attached. 

With virt-install, it can be achieved with multiple --disk parameters, i.g.

```yaml
- name: install worker node
  shell: >-
    virt-install
    --name {{item.name}}
    --hvm
    --virt-type kvm
    --pxe
    --arch x86_64
    --os-type linux
    --os-variant rhel8.0
    --network network=openshift,mac="52:54:00:00:01:{{item.mac}}"
    --vcpus {{spec_worker.cpu}}
    --cpu host-passthrough,cache.mode=passthrough,cell0.memory={{ spec_worker.ram * 512 }},cell0.cpus=0-{{ spec_worker.cpu // 2 - 1 }},cell1.memory={{ spec_worker.ram * 512 }},cell1.cpus={{ spec_worker.cpu // 2 }}-{{ spec_worker.cpu - 1 }}
    --ram {{spec_worker.ram}}
    --disk pool=openshift,size={{spec_worker.disk1}},format=qcow2,cache={{ spec_worker.disk_cache }}
    --disk pool=openshift,size={{spec_worker.disk2}},format=qcow2,cache={{ spec_worker.disk_cache }}
    --disk pool=openshift,size={{spec_worker.disk3}},format=qcow2,cache={{ spec_worker.disk_cache }}
    --check disk_size=off
    --nographics
    --noautoconsole
    --boot menu=on,useserial=on
  with_items: "{{ worker }}"
```

Worker Nodes Disks:

```shell
kni@bzhai-hive ~ $ ssh core@worker-0 lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
vda    252:0    0   128G  0 disk 
vda1 252:1    0     1M  0 part 
vda2 252:2    0   127M  0 part 
vda3 252:3    0   384M  0 part /boot
vda4 252:4    0 127.5G  0 part /sysroot
vdb    252:16   0    50G  0 disk 
vdc    252:32   0    50G  0 disk

kni@bzhai-hive ~ $ ssh core@worker-1 lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0    7:0    0    50G  0 loop 
vda    252:0    0   128G  0 disk 
vda1 252:1    0     1M  0 part 
vda2 252:2    0   127M  0 part 
vda3 252:3    0   384M  0 part /boot
vda4 252:4    0 127.5G  0 part /sysroot
vdb    252:16   0    50G  0 disk 
vdc    252:32   0    50G  0 disk 

kni@bzhai-hive ~ $ ssh core@worker-2 lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
vda    252:0    0   128G  0 disk 
vda1 252:1    0     1M  0 part 
vda2 252:2    0   127M  0 part 
vda3 252:3    0   384M  0 part /boot
vda4 252:4    0 127.5G  0 part /sysroot
vdb    252:16   0    50G  0 disk 
vdc    252:32   0    50G  0 disk 

```

### Install Local Storage Operator

Follow document below to install Local Storage Operator: 
https://docs.openshift.com/container-platform/4.8/storage/persistent_storage/persistent-storage-local.html#local-storage-install_persistent-storage-local 

### Create LocalVolume, PV

```yaml
apiVersion: "local.storage.openshift.io/v1"
kind: "LocalVolume"
metadata:
  name: "local-disks"
  namespace: "openshift-local-storage" 
spec:
  nodeSelector: 
    nodeSelectorTerms:
    - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - worker-0
          - worker-1
          - worker-2
  storageClassDevices:
    - storageClassName: "localblock-sc" 
      volumeMode: Filesystem  
      devicePaths: 
        - /dev/vdb
        - /dev/vdc
```

PV will be created automatically:

```shell
kni@bzhai-hive ~ $ oc get pv
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM    STORAGECLASS    REASON   AGE
local-pv-33eb9803   50Gi       RWO            Delete           Available            localblock-sc            36m
local-pv-3801d58c   50Gi       RWO            Delete           Available            localblock-sc            36m
local-pv-3fd0b1f2   50Gi       RWO            Delete           Available            localblock-sc            36m
local-pv-a53d9411   50Gi       RWO            Delete           Available            localblock-sc            36m
local-pv-e8bb96dd   50Gi       RWO            Delete           Available            localblock-sc            36m
local-pv-facd92d8   50Gi       RWO            Delete           Available            localblock-sc            36m
```

### Set Default StorageClass

```shell
kubectl patch storageclass localblock-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

```
### Create PVC

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: local-pvc-name 
spec:
  accessModes:
  - ReadWriteOnce
  volumeMode: Filesystem 
  resources:
    requests:
      storage: 10Gi 
  storageClassName: localblock-sc
```

### Create Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: pod-test
  name: pod-test
spec:
  containers:
  - image: quay.io/bzhai/nginx
    name: pod-test
    volumeMounts:
    - mountPath: "/localdata"
      name: localpvc
  volumes:
  - name: localpvc
    persistentVolumeClaim:
      claimName: local-pvc-name
  dnsPolicy: ClusterFirst
  restartPolicy: Always
```

### Verification

```shell
kni@bzhai-hive ~ $ oc get localvolume,pv,pvc,pod,storageclass
NAME                                 CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                    STORAGECLASS    REASON   AGE
persistentvolume/local-pv-33eb9803   50Gi       RWO            Delete           Available                            localblock-sc            36m
persistentvolume/local-pv-3801d58c   50Gi       RWO            Delete           Bound       default/local-pvc-name   localblock-sc            36m
persistentvolume/local-pv-3fd0b1f2   50Gi       RWO            Delete           Available                            localblock-sc            36m
persistentvolume/local-pv-a53d9411   50Gi       RWO            Delete           Available                            localblock-sc            36m
persistentvolume/local-pv-e8bb96dd   50Gi       RWO            Delete           Available                            localblock-sc            36m
persistentvolume/local-pv-facd92d8   50Gi       RWO            Delete           Available                            localblock-sc            36m

NAME                                   STATUS   VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS    AGE
persistentvolumeclaim/local-pvc-name   Bound    local-pv-3801d58c   50Gi       RWO            localblock-sc   20m

NAME           READY   STATUS    RESTARTS   AGE
pod/pod-test   1/1     Running   0          15m

NAME                                        PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
storageclass.storage.k8s.io/localblock-sc   kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  36m
```