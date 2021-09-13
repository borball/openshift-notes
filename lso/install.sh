#!/bin/bash

#create namespace
oc adm new-project openshift-local-storage

OC_VERSION=$(oc version -o yaml | grep openshiftVersion | grep -o '[0-9]*[.][0-9]*' | head -1)

#create operator group
cat <<EOF | oc create -f -
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: local-operator-group
  namespace: openshift-local-storage
spec:
  targetNamespaces:
    - openshift-local-storage
EOF

#create subscriiption
cat <<EOF | oc create -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: local-storage-operator
  namespace: openshift-local-storage
spec:
  channel: "${OC_VERSION}"
  installPlanApproval: Automatic 
  name: local-storage-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

until oc -n openshift-local-storage get pods | grep -m 1 "Running"; do sleep 1; done

oc get csvs -n openshift-local-storage

#create local volume
cat <<EOF | oc create -f -
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
          - openshift-master-0 
          - openshift-master-1
          - openshift-master-2
  storageClassDevices:
    - storageClassName: "local-storage" 
      volumeMode: Filesystem  
      devicePaths: 
        - /dev/vdb
EOF

#set default storage class
oc patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

#test
cat <<EOF | oc create -f -
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
  storageClassName: local-storage
EOF

cat <<EOF | oc create -f -
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
EOF

until oc get pods | grep -m 1 "Running"; do sleep 1; done
oc exec -it pod-test -- touch /localdata/test.txt
oc exec -it pod-test -- ls /localdata 

if [ $(oc exec -it pod-test -- ls /localdata |grep test.txt | wc -l) -eq 1 ]
then
  echo "Local Storage Operator was installed successfully."
else
  echo "Pod pod-test cannot use pvc, please check"
fi

oc delete pod pod-test
oc delete pvc local-pvc-name
oc get pv 
oc get LocalVolume -n openshift-local-storage
