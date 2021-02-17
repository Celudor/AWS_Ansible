# PoC - Servers monitoring with Prometheus and Grafa build on AWS EC2 using Ansible

## Setup environemt

### Ansible installation on workstation

I'm using Ubuntu 20.04 LTS installed on WSL2.

```sh
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```
After installing ansible, I modify its settings creating the local cfg file (`~/.ansible.cfg`) in my home directory.
```cfg
[defaults]
host_key_checking = False
```

### The installation required ansible roles and collections
I use command `ansible-glaxy` to install roles and collections defined in `./ansible/requirements.yaml` file.
```sh
ansible-galaxy role install -r ./ansible/requirements.yaml
ansible-galaxy collection install -r ./ansible/requirements.yaml
```

### Setup AWS access key and secret
AWS access key and secret are stroed as variable in `./ansible/group_vars/all/pass.yml`. This file is encoded by `ansible-vault`. I can edit it usnig command: `ansible-vault edit ./ansible/group_vars/all/pass.yml`
Content of `pass.yml` file:
```yml
ec2_access_key: KIA2AEPAUQATJR7CKQQ # Put your access key here
ec2_secret_key: X7IEq2gdFkarOH2m7zK7AH89y6sRQZzFLcaIjBFb # Put your secret here
grafana_admin_password: password # Password for grafana admin
```