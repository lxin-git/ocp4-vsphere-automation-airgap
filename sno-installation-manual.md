# sno installation


- Access the Assisted Installer
https://console.redhat.com/openshift/assisted-installer/clusters

- click `Create Cluster`
- input `Cluster name` and `Base domain`, select `OpenShift version`, check `Install single node OpenShift(SNO)`, then click `Next`

![](media/16479562340514/16479590446260.jpg)

- Now Open the browser debug tool (chrome), check the element from Network recording. You need find the `AI_SVC_API_TOKEN` and `AI_SVC_INFRA_ENV_ID` (cluster id can also be found from the browser url address)

![](media/16479562340514/16479619549945.jpg)



- Prepare the token vars

```
AI_SVC_ENDPOINT="https://api.openshift.com"
AI_SVC_INFRA_ENV_ID="<infra env id in above pic>"
AI_SVC_CLUSTER_SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
AI_SVC_API_TOKEN="<api token in above picture>"
```

- Create the NMState YAML

```
NMSTATE_BODY=$(mktemp)
cat << EOF > $NMSTATE_BODY
dns-resolver:
  config:
    server:
    - 172.112.252.58
    - 172.110.183.72
interfaces:
- name: ens192
  ipv4:
    address:
    - ip: 172.112.238.113
      prefix-length: 24
    dhcp: false
    enabled: true
  state: up
  type: ethernet
routes:
  config:
  - destination: 0.0.0.0/0
    next-hop-address: 172.112.238.1
    next-hop-interface: ens192
    table-id: 254
EOF
```

- Create the complete JSON request body

create the vm in vcenter and get the mac address:

![](media/16479562340514/16479602584618.jpg)


append JSON request body:
```
JSON_BODY=$(mktemp)
jq -n --arg SSH_KEY "$AI_SVC_CLUSTER_SSH_PUBLIC_KEY" --arg NMSTATE_YAML "$(cat $NMSTATE_BODY)" \
'{
  "ssh_authorized_key": $SSH_KEY,
  "image_type": "full-iso",
  "static_network_config": [
    {
      "network_yaml": $NMSTATE_YAML,
      "mac_interface_map": [{"mac_address": "00:50:56:8e:87:29", "logical_nic_name": "ens192"}]
    }
  ]
}' > $JSON_BODY
```

- Configure the Discovery ISO

```
curl -H "Content-Type: application/json" -X PATCH -d @$JSON_BODY "${AI_SVC_ENDPOINT}/api/assisted-install/v2/infra-envs/${AI_SVC_INFRA_ENV_ID}" -H "Authorization: Bearer ${AI_SVC_API_TOKEN}"
```
```
[sno@xtool1 ~]$ curl -H "Content-Type: application/json" -X PATCH -d @$JSON_BODY "${AI_SVC_ENDPOINT}/api/assisted-install/v2/infra-envs/${AI_SVC_INFRA_ENV_ID}" -H "Authorization: Bearer ${AI_SVC_API_TOKEN}"
{"cluster_id":"30639ea5-3fe4-479b-bfa7-de6fae4f11b0","cpu_architecture":"x86_64","created_at":"2022-03-22T16:43:17.387308Z","download_url":"https://api.openshift.com/api/assisted-images/images/28f4dcec-18da-41f7-b10c-cd7f97eac62f?arch=x86_64&image_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDc5ODE4OTcsInN1YiI6IjI4ZjRkY2VjLTE4ZGEtNDFmNy1iMTBjLWNkN2Y5N2VhYzYyZiJ9.nlQPH9vjNYtOom4RlUCZkWQ_JAN4UuZEY7NVjM6V2yc&type=full-iso&version=4.10","email_domain":...<omitted>...}
```
You will see the `download_url`


- Download

```
wget -O discovery_image_sno410.iso 'https://api.openshift.com/api/assisted-images/images/28f4dcec-18da-41f7-b10c-cd7f97eac62f?arch=x86_64&image_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDc5ODE4OTcsInN1YiI6IjI4ZjRkY2VjLTE4ZGEtNDFmNy1iMTBjLWNkN2Y5N2VhYzYyZiJ9.nlQPH9vjNYtOom4RlUCZkWQ_JAN4UuZEY7NVjM6V2yc&type=full-iso&version=4.10'
```

- Connect ISO to VM CD-ROM driver and power on VM

- Continue the assistant installation

change the hostname once you can see the host in list.
![](media/16479562340514/16479682012467.jpg)

after change the hostname, click `Next`
select `Available subnets`, click `Next`
click `Install cluster`

wait for finish.



## deploy hostpath provisioner

```
kubectl create -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml
kubectl create -f https://raw.githubusercontent.com/kubevirt/hostpath-provisioner-operator/main/deploy/namespace.yaml
kubectl create -f https://raw.githubusercontent.com/kubevirt/hostpath-provisioner-operator/main/deploy/webhook.yaml -n hostpath-provisioner
kubectl create -f https://raw.githubusercontent.com/kubevirt/hostpath-provisioner-operator/main/deploy/operator.yaml -n hostpath-provisioner
```

Create following CR & SC:
```
cat << EOF | oc apply -f -
apiVersion: hostpathprovisioner.kubevirt.io/v1beta1
kind: HostPathProvisioner
metadata:
  name: hostpath-provisioner
spec:
  imagePullPolicy: Always
  storagePools:
    - name: "local"
      path: "/var/hpvolumes"
  workload:
    nodeSelector:
      kubernetes.io/os: linux
EOF
```

```
cat << EOF | oc apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: hostpath-csi
provisioner: kubevirt.io.hostpath-provisioner
reclaimPolicy: Delete
parameters:
  storagePool: local
EOF
```
