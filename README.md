# Virtualization and Cloud Computing

Authors: Simone Aquilini (s5667729) - Luca Ferrari (s4784573) - Lorenzo La Corte (s4784539)

# Notes 

## Task 1

- created machines
  VMs are named VM1 and VM2, hard disk is 20GB and memory is 4096MB
  We had to set VM1's HD storage to 30GB to solve some memory related issues.
- configured ssh 
- change hostnames: node1, node2
- create 2 network adapters:
  - 192.168.50.0/24 for the external net (VMNet8 - adapter 1): Internet access via NAT and reachable by the host (it's the gateway)
  - 10.255.255.0/24 for the storage net (VMNet3 - adapter 2): No internet access and non reachable by the host
- configure static IP: 
  - x.x.x.10 for VM1
  - x.x.x.20 for VM2
- configure names: update the hosts file of the host machine (c:\Windows\System32\Drivers\etc\hosts)
  - 192.168.50.10 VM1
  - 192.168.50.20 VM2

## Task 2,3,4

#### Configuring Ansible
- set up inventory.yml file with:  
  - NFS configuration for 2 nodes: nfs-client and nfs-server
  - set up of ssh key on both nodes
- create and configure the 2 roles: nfs-client and nfs-server
- change playbook.yml adding host nfs-server and nfs-client
- change requirements.yml
- change makefile

#### Configuring Network
- change netplan configuring storage network
  - 10.255.255.10 for node1
  - 10.255.255.20 for node2

#### Configuring SSH
- ssh-keygen --> it generates keys in /home/node1/.ssh

- from the folder /home/node1/.ssh
  - ssh-copy-id node1@192.168.50.10
  - ssh node1@192.168.50.10 # should not request pwd

  - ssh-copy-id node2@192.168.50.20
  - ssh node2@192.168.50.20 # should not request pwd

- then, in inventory we can set:
      ansible_ssh_private_key_file: /home/node1/.ssh/id_rsa

#### Troubleshooting "Missing sudo password"
- in node1:
  - sudo nano /etc/sudoers.d/devops # insert a line
  - node1 ALL=(ALL) NOPASSWD: ALL

- in node2:
  - sudo nano /etc/sudoers.d/devops # insert a line
  - node2 ALL=(ALL) NOPASSWD: ALL
 
## Task 5,6
- follow: https://www.ansiblepilot.com/articles/install-docker-in-debian-like-systems-ansible-module-apt_key-apt_repository-and-apt/

- 4 tasks:
  - Allow apt to use a repository over HTTPS (ansible.builtin.apt)
  - Download the GPG signature key for the repository (ansible.builtin.apt_key)
  - Add the add Docker repository to the distribution (ansible.builtin.apt_repository)
  - Update the apt cache for the available packages and install Docker (ansible.builtin.apt)

- Notes:
  - apt-get update --> "update_cache: true" in ansible.builtin.apt
  - ansible_distribution and ansible_architecture are magic variables
    - to use them in links we have to lowercase them -> | lower

## Task 7,8,9

#### Docker Swarm Manager
- Init a new swarm with default parameters

#### Docker Swarm Client
- join to the swarm using hostvars for addresses and token 

## Task 10, 11, 12, 13
- create 3 roles:
#### registry (server)
- it deploys the registry on the server/manager
  - enabling TLS using certificates under the folder /data/docker-registry/certs
  - setting up authentication through htpasswd
    - using bcrypt as scheme (the only one supported)
    - generating username and password each time randomly

#### registry-tls-common (all)
- it instructs all single docker hosts to trust TLS certificate copying ca cert inside /etc/docker/certs.d/10.255.255.10:5000

#### registry-login (all)
- each node logs in leveraging docker_login module
  - using TLS certificates (insecure registry solved)
  - using randomly generated username and password

## Task 14,15,16
- deploy one and shared postgres instance through docker compose 
- database role: update the entrypoint in order to call sql scripts DBs keycloak and nextcloud

## Task 17-25

#### keycloack
- deploy the service on compose
- *--import-realm* is used to import a config .json file automatically from the default folder
- some other flags are used to enable logging and rev-proxy integration
- the .json file is used to easily configure realm, clients and users

#### nextcloud and integration, sto maledetto
- a custom image is build starting from the one given:
  - entrypoint is a new one, which aim is to call the default one and then apply the required modifications for the integration
  - in particular, our entrypoint has to do its commands with sudo in order to has www-data permissions and -E set to preserve their existing environment variables 
- extra-hosts are set in order to enable the oidc auto-redirection

## Task 26-31

#### traefik
- all container are attached to the same overlay network
- traefik config through commands in the compose, ports 80 and 443 are exposed
- all services have the necessary labels for configuring websecure redirection

## Task 32-50

#### fluent-bit
- compose is used to deploy the service on both nodes and mount config files
- a configuration file is set to:
  - collect logs from each container and send them to loki
  - collect metrics with node_exporter and expose them through a http endpoint
- the config is templated by each node in order to label correctly each log with the source node

#### loki
- is deployed through compose with default config and simply stores logs

#### prometheus
- is deployed through compose with flag that set retention time and config file
- its config file exploits docker socket to collect metrics and relabel them thanks to the labels set in the compose

#### grafana
- datasources are configured (loki and prometheus)
- openid is enabled

# Facilities available

- `make run-ansible` runs the Ansible playbook
- `make run-ansible-lint` runs the Ansible playbook linter
- An example inside of `examples` of the integration between Nextcloud and Keycloak

# TO-DO
Listed by priority:
- keycloak entrypoint modification in order to wait for postgres
- template secrets
- join registry-tls-common and registry-login
- loki for prom endpoint is still necessary?