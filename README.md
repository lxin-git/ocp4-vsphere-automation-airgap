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
