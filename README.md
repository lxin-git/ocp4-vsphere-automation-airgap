# ocp4-vsphere-automation

Not transfer to tower yet. but it will be easy...
From your ansible control manager host, make sure pyvmomi module installed for your ansible python env.
Enable epel repo, then:
```
yum install python2-pip
```
or `python3-pip`, depends on your python version used by ansible
```
pip install PyVmomi
```

```
git clone https://github.com/lxin-git/ocp4-vsphere-automation.git
cd ocp4-vsphere-automation
cp all.yml.sample all.yml
vi all.yml
ansible-playbook start.yml
```
Updated for tower run:
```
ansible-playbook tower_start.yml -e @myocpconfig.yml
```

Updated for create offline ova:
```
ansible-playbook airgap_create_infra_ova.yml -e @mcm-airgap-infra.yml -e '{skip_sync_mirror: true}'
```

If you have vcenter access, to install from infra node in a restricted network:
```
scp image_mirror_ocp_release_4.5.20.tar.gz root@9.112.238.116://root/ocp4-vsphere-automation/
cd /root/ocp4-vsphere-automation/ && tar xvf image_mirror_ocp_release_4.5.20.tar.gz
# change registry.offline_image_path to /root/ocp4-vsphere-automation/
ansible-playbook tower_start.yml -e @mcm-airgap-infra.yml -e '{restricted_network: true}'
```
If you do not have vcenter access, to create all the iso from infra node in a restricted network:
```
ansible-playbook airgap_create_iso.yml -e @mcm-airgap-infra.yml -e '{restricted_network: true}'
```


## magic parameters
skip_download_ova
skip_sync_mirror
clean
restricted_network

If you have you existing infra node deployed and finished all package install and image download, when you rerun the playbook, it will not download again, you can force clean existing download by `-e clean=true`

If you have you existing infra node deployed and finished ova download for ocp4.6+, you can use `-e skip_download_ova=true`

In some cases of airgap installation, you may need create a smaller ova template for vsphere to import, and you don't want the ocp mirror data included in the ova, you can use `-e skip_sync_mirror`. with this parameter, the 6+ G mirror data won't be included in the infra node ova file, you should mirror it your self and copy to the infra node before run the actual deployment playbook.

To manually generate the mirror data, here is the exampe:
```
export OCP_RELEASE='4.5.20'
export LOCAL_REGISTRY='xbox-mirror.fyre.ibm.com:5000'
export LOCAL_REPOSITORY='ocp4/openshift4'
export PRODUCT_REPO='openshift-release-dev'
export LOCAL_SECRET_JSON='/data/images/mirror-data/pull-secret.json'
export RELEASE_NAME="ocp-release"
export ARCHITECTURE='x86_64'
export REMOVABLE_MEDIA_PATH='/data/images/mirror-data/ocp4.5.20'
./oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${REMOVABLE_MEDIA_PATH}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE}

# The mirror data will be stored in /data/images/mirror-data/ocp4.5.20/mirror
```


## Known issue

- ansible vmware_guest module create the same vm name in different folder not work: https://github.com/ansible/ansible/pull/60679
  `vi /usr/local/Cellar/ansible/2.8.5/libexec/lib/python3.7/site-packages/ansible/module_utils/vmware.py`
  ```
  if len(vms) > 1:
  to
  if len(vms) >= 1:
  ```

- ansible create vm encounter "Failed to create a virtual machine : A specified parameter was not correct: disk[0].diskId": https://github.com/ansible/ansible/issues/57653

  `vi /usr/local/Cellar/ansible/2.8.5/libexec/lib/python3.7/site-packages/ansible/modules/cloud/vmware/vmware_guest.py`
  ```
   if hasattr(device.backing, 'fileName'):
   to
   if hasattr(device.backing, 'fileName') and hasattr(device.backing, 'diskMode'):
  ```
