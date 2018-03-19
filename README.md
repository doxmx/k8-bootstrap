# Kubernetes Cluster Bootstrapping Playbook.

## Table of Contents:

1. [Overview](#overview)
1. [Nodes requirements](#nodes-requirements)
1. [Ansible's Inventory File](#ansible-inventory-file)
1. [Configuring the playbook](#configuring-the-playbook)
1. [Boostrapping the nodes](#bootstrapping-the-nodes)
1. [Validation](#validation)

## Overview.

Ansible playbook to bootstrap custom instances for a Rancher kubernetes environment. The playbook will install the required components on the instances and register the hosts agains a previously configured kubernetes cluster managed by Rancher. 

## Setting up the environment.

### Nodes requirements:
1. A Kubernetes rancher environment. 
1. A Rancher host registration URL for the desired environment.
1. Operating system: Linux. This has been tested on Ubuntu 16.04.
1. Python 2.7 or higher.
1. Open SSH Server installed and running.
1. SSH Keys authentication configured between the ansible workstation and the hosts (recommended).
1. Username to perform the bootstrapping. It needs to be able to run commands with sudo. 

### Ansible inventory file.

The ansible playbook requires an inventory file, it contains the list of servers to be bootstrapped under the kube group.
```
$ cat inventory 
[kube]
192.168.1.85
192.168.1.86
```

### Configuring the playbook.
Configure the following playbook variables.
```
# IP address of the NIC to be used to register the node in rancher. 
host_ip: "{{ ansible_enp0s3.ipv4.address }}" 

# Registration URL. Obtained from Environment/Infrastructure/Add Host/
user_name: kube # Local username on the instance that will be added to the docker group.
rancher_agent_command: http://IP_ADDRESS:8080/v1/scripts/REGISTRATION_TOKEN_VARIABLES  

# URL to the docker installer script.
docker_url: https://releases.rancher.com/install-docker/1.12.sh 

# Docker image of the rancher agent that will be executed on the nodes. 
rancher_image: rancher/agent:v1.2.7 
```

### Bootstrapping the nodes.
Cluster nodes will be boostrapped by running the ansible playbook and providing as parameter the inventory file.

Example:

```
$ ansible-playbook -u kube -i inventory --ask-sudo-pass playbook.yml
SUDO password: 

PLAY [kube] **************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************
ok: [192.168.1.86]
ok: [192.168.1.85]

TASK [update apt; autoremoves old] *******************************************************************************************************************************************************
changed: [192.168.1.85]
changed: [192.168.1.86]

TASK [remove docker version] *************************************************************************************************************************************************************
changed: [192.168.1.85]
changed: [192.168.1.86]

TASK [install pip] ***********************************************************************************************************************************************************************
ok: [192.168.1.85]
ok: [192.168.1.86]

TASK [stop all containers and kill any rancher agent daemons] ****************************************************************************************************************************
changed: [192.168.1.85]
changed: [192.168.1.86]

TASK [unmount docker artifacts] **********************************************************************************************************************************************************
ok: [192.168.1.85]
ok: [192.168.1.86]

TASK [remove docker artifacts] ***********************************************************************************************************************************************************
changed: [192.168.1.85]
changed: [192.168.1.86]

TASK [remove rancher artifacts] **********************************************************************************************************************************************************
ok: [192.168.1.85]
ok: [192.168.1.86]

TASK [Download docker-engine install script] *********************************************************************************************************************************************
ok: [192.168.1.85]
ok: [192.168.1.86]

TASK [Install docker engine] *************************************************************************************************************************************************************
changed: [192.168.1.85]
changed: [192.168.1.86]

TASK [Add docker user to group for no sudo] **********************************************************************************************************************************************
changed: [192.168.1.86]
changed: [192.168.1.85]

TASK [install python docker package] *****************************************************************************************************************************************************
ok: [192.168.1.85]
ok: [192.168.1.86]

TASK [Create rancher agent container] ****************************************************************************************************************************************************
changed: [192.168.1.86]
changed: [192.168.1.85]

PLAY RECAP *******************************************************************************************************************************************************************************
192.168.1.85               : ok=13   changed=7    unreachable=0    failed=0   
192.168.1.86               : ok=13   changed=7    unreachable=0    failed=0 
```

### Validation.

After the nodes bootstrapping, the nodes will be running the rancher agent. And the nodes will start downloading and creating the kubernetes infrastructure services. 
```
# docker ps 
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS               NAMES
3dc2f43d5bde        rancher/agent:v1.2.5   "/run.sh run"       44 seconds ago      Up 44 seconds                           rancher-agent
```

The status of the kubernetes cluster can be verified in Environment/Infrastructure section in the Rancher GUI's. 

