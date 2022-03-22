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
AI_SVC_INFRA_ENV_ID="28f4dcec-18da-41f7-b10c-cd7f97eac62f"
AI_SVC_CLUSTER_SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
AI_SVC_API_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICItNGVsY19WZE5fV3NPVVlmMkc0UXhyOEdjd0l4X0t0WFVDaXRhdExLbEx3In0.eyJleHAiOjE2NDc5NjgwNjMsImlhdCI6MTY0Nzk2NzE2MywiYXV0aF90aW1lIjoxNjQ3OTUyOTc3LCJqdGkiOiI1NTM0NzBkMC05NWRiLTQxZTctYTUyNy1hNDg4MzRiZGE3ZDUiLCJpc3MiOiJodHRwczovL3Nzby5yZWRoYXQuY29tL2F1dGgvcmVhbG1zL3JlZGhhdC1leHRlcm5hbCIsImF1ZCI6ImNsb3VkLXNlcnZpY2VzIiwic3ViIjoiZjo1MjhkNzZmZi1mNzA4LTQzZWQtOGNkNS1mZTE2ZjRmZTBjZTY6bGxpeGlubiIsInR5cCI6IkJlYXJlciIsImF6cCI6ImNsb3VkLXNlcnZpY2VzIiwibm9uY2UiOiJlMDEzNDFmYi05NGYyLTQ5OGYtODMzMy01M2FhNDc3Yjg4NzkiLCJzZXNzaW9uX3N0YXRlIjoiZWJiOWYwNDgtZDdjMC00YmY2LThhYzctYjEyMTJjZmNmYWEzIiwiYWNyIjoiMCIsImFsbG93ZWQtb3JpZ2lucyI6WyJodHRwczovL3Byb2QuZm9vLnJlZGhhdC5jb206MTMzNyIsImh0dHBzOi8vY29uc29sZS5kZXYucmVkaGF0LmNvbSIsImh0dHBzOi8vcWFwcm9kYXV0aC5jb25zb2xlLnJlZGhhdC5jb20iLCJodHRwczovL2dvdi5jb25zb2xlLnJlZGhhdC5jb20iLCJodHRwczovL3FhcHJvZGF1dGguZm9vLnJlZGhhdC5jb20iLCJodHRwczovL2FwaS5jbG91ZC5yZWRoYXQuY29tIiwiaHR0cHM6Ly9xYXByb2RhdXRoLmNsb3VkLnJlZGhhdC5jb20iLCJodHRwczovL2Nsb3VkLm9wZW5zaGlmdC5jb20iLCJodHRwczovL3Byb2QuZm9vLnJlZGhhdC5jb20iLCJodHRwczovL2Nsb3VkLnJlZGhhdC5jb20iLCJodHRwczovL2NvbnNvbGUucmVkaGF0LmNvbSJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiYXV0aGVudGljYXRlZCIsInBvcnRhbF9tYW5hZ2Vfc3Vic2NyaXB0aW9ucyIsImFkbWluOm9yZzphbGwiLCJwb3J0YWxfbWFuYWdlX2Nhc2VzIiwicG9ydGFsX3N5c3RlbV9tYW5hZ2VtZW50IiwicG9ydGFsX2Rvd25sb2FkIl19LCJzY29wZSI6Im9wZW5pZCIsInNpZCI6ImViYjlmMDQ4LWQ3YzAtNGJmNi04YWM3LWIxMjEyY2ZjZmFhMyIsImFjY291bnRfbnVtYmVyIjoiNjUyMzc0MSIsImlzX2ludGVybmFsIjpmYWxzZSwiaXNfYWN0aXZlIjp0cnVlLCJsYXN0X25hbWUiOiJMaSIsInByZWZlcnJlZF91c2VybmFtZSI6ImxsaXhpbm4iLCJ0eXBlIjoiVXNlciIsImxvY2FsZSI6InpoX0NOIiwiaXNfb3JnX2FkbWluIjp0cnVlLCJhY2NvdW50X2lkIjoiNTMwNDkwMTEiLCJvcmdfaWQiOiIxMjkxMDg4MSIsImZpcnN0X25hbWUiOiJYaW4iLCJlbWFpbCI6ImxsaXhpbm5AY24uaWJtLmNvbSIsInVzZXJuYW1lIjoibGxpeGlubiJ9.enbiEFhqt8OF5fWbVCA7RGazB3DcWUDfsiZ5Y_29DkMm2tk2YQvlBa_3vJDhKKj5cw4-9rScs2qyEUbmnlph8aayAG7sGNxjnrOd7JOrA9dOxBYmOJY8KgIufP1rqLHwz7XRgRYKScXkSL4tTwpJJwSsUjukMlhXPe19apj75TGJy5RW-7EKi3kQ8HhdM8SYK3Ablt4O6_XrhhdCC8CIae06szRiwpDDiiVZwr4TW0L7_vnJIzodVZEH85V458k-8sbAG5Onjmu2Gq01_vEkTYxpkpWJOh784lVEyg0sCww4iQDj-lrrEhNGqjgmYgV7VKPDEKU3DyYLV9sH6L1dCeQ8ULY2IYGXdbFZivNCDciZlbNKcyyMQfxt6egHS8-RpE_Ul0E4x3OQAXO3RgxKwH6TCYgGL4tB7WUU5N7BnEBEjfHrL_NlJNcim7ORc6zpmLZ057QDpCwS01dWnfKGHGkUDgAJJ8XUXil3aXdlD9oK8m01njqlwzBauskzrJlcEbhqO3X4g-gjEKmjHTwRDRFUH0hlDyUeslup4TGtpAVt6C58_F358GD0SHYvki1w0ByGe8A54qINCxk1YZN9wsMz_6-J2HOTTH_GxOYXtyhItRfDK58WHjFxJyjIiWqVgdd7IdtMwOtXNN5Bt6t1GhCTccsUVOn-KoJKaI9lQ1o"
```

- Create the NMState YAML

```
NMSTATE_BODY=$(mktemp)
cat << EOF > $NMSTATE_BODY
dns-resolver:
  config:
    server:
    - 9.112.252.58
    - 9.110.183.72
interfaces:
- name: ens192
  ipv4:
    address:
    - ip: 9.112.238.113
      prefix-length: 24
    dhcp: false
    enabled: true
  state: up
  type: ethernet
routes:
  config:
  - destination: 0.0.0.0/0
    next-hop-address: 9.112.238.1
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
{"cluster_id":"30639ea5-3fe4-479b-bfa7-de6fae4f11b0","cpu_architecture":"x86_64","created_at":"2022-03-22T16:43:17.387308Z","download_url":"https://api.openshift.com/api/assisted-images/images/28f4dcec-18da-41f7-b10c-cd7f97eac62f?arch=x86_64&image_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDc5ODE4OTcsInN1YiI6IjI4ZjRkY2VjLTE4ZGEtNDFmNy1iMTBjLWNkN2Y5N2VhYzYyZiJ9.nlQPH9vjNYtOom4RlUCZkWQ_JAN4UuZEY7NVjM6V2yc&type=full-iso&version=4.10","email_domain":"cn.ibm.com","expires_at":"2022-03-22T20:44:57.000Z","href":"/api/assisted-install/v2/infra-envs/28f4dcec-18da-41f7-b10c-cd7f97eac62f","id":"28f4dcec-18da-41f7-b10c-cd7f97eac62f","kind":"InfraEnv","name":"sno410_infra-env","openshift_version":"4.10","org_id":"12910881","proxy":{},"pull_secret_set":true,"ssh_authorized_key":"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCplu10AhHZcVE6gTktk4ry4JqbsBgft8tbr7wQePyjC5lcnXEEVB6/VXL7oOwL59bOxCUP/c+2mPP2ijxslXHN5VnODJWwhCrsNKFfCIOkytzzZc9hVb9q2ivpBsrr6poW76rfm0yyWk3ckyQ7CQJE4bym4UBQ3cK2Cl5UzDLmuWdvts+PJ6M7gyH1zP+8EEWKsf+RWKjMExsWmVETBzD9WKLUBk59nHOos09xdAeFz8glIP8E3qUzEdKC8MxLZgidVMjVJ18XDrV9Ijjzl1Vth4FsxqrS6T9p/HYC/g+TYSKVnkXDcG0hHcezxz8BYZANWaiIIO9McNA5C0e1klSR9PA9QTpq0yAyg/hpVUhad8ozlVQkpbrIQ565F4wx9rooeA8hXyAiX1o9s8VVZ+y7yjNmdhk0eZda32fPJM9tfzRY3mVPOeXrMJKo7RbyMnYx/ysx00QLs2tEIwpR0ZSGCZiMnOnmNl3CutGzh2UM/keK2ZIjKpkoQRa3Q+XhrkU= sno@xtool1.fyre.ibm.com","static_network_config":"dns-resolver:\n  config:\n    server:\n    - 9.112.252.58\n    - 9.110.183.72\ninterfaces:\n- name: ens192\n  ipv4:\n    address:\n    - ip: 9.112.238.113\n      prefix-length: 24\n    dhcp: false\n    enabled: true\n  state: up\n  type: ethernet\nroutes:\n  config:\n  - destination: 0.0.0.0/0\n    next-hop-address: 9.112.238.1\n    next-hop-interface: ens192\n    table-id: 254HHHHH00:50:56:8e:87:29=ens192","type":"full-iso","updated_at":"2022-03-22T16:44:58.475871Z","user_name":"llixinn"}
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
