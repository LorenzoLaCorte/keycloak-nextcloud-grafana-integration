# Virtualization and Cloud Computing

Authors: Simone Aquilini (s5667729) - Luca Ferrari (s4784573) - Lorenzo La Corte (s4784539)

## Notes 

### Task 1

- created machines
  VMs are named VM1 and VM2, hard disk is 20GB and memory is 4096MB
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

---> Snapshot Taken: task1

### Task 2,3,4

#### Configuring Ansible
- set up inventory.yml file with  
  - NFS configuration for 2 nodes: nfs-client and nfs-server
  - set up of ssh key on both nodes
- create and configure the 2 roles nfs-client and nfs-server
- change playbook.yml adding host nfs-server and nfs-client
- change requirements.yml
- change makefile

#### Configuring Network
- changed netplan configuring storage network
  - 10.255.255.10 for node1
  - 10.255.255.20 for node2

#### Configuring SSH
- ssh-keygen # it generates keys in /home/node1/.ssh

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

--> Snapshot Taken: task4
 
### Task 5,6
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

--> Snapshot Taken: task6

### Task 7,8,9
- create 2 roles:
#### Docker Swarm Manager
- Init a new swarm with default parameters

#### Docker Swarm Client
- join to the swarm using hostvars for addresses and token 

### Task 10, 11, 12, 13
- create 3 roles:
#### registry
- it deploys the registry on the server/manager
  - enabling TLS using certificates under the folder /data/docker-registry/certs
  - setting up authentication through htpasswd
    - using bcrypt as scheme (the only one supported)
    - generating username and password each time randomly

#### registry-tls-common
- it instructs all single docker hosts to trust TLS certificate copying ca cert inside /etc/docker/certs.d/10.255.255.10:5000

#### registry-client
- each client logs in leveraging docker_login module
  - using TLS certificates (insecure registry solved)
  - using randomly generated username and password
  
### Task 14,15,16
- update database role:
  - each service has its own db
  - posttgres DB, user and pass are vcc-test
  - update the entrypoint in order to call sql scripts and create
    - DBs keycloak and nextcloud (user and pass use the same name) 


## Facilities available

- `make run-ansible` runs the Ansible playbook
- `make run-ansible-lint` runs the Ansible playbook linter
- An example inside of `examples` of the integration between Nextcloud and Keycloak

## 🔫🔫🔫
RoyalL, ShottaS, and BiggyL had lent a large sum of money to a man named Docker, and he had failed to pay them back on time. They were fed up with waiting and decided to track him down and confront him about the debts.

They searched high and low, using every resource at their disposal to locate Docker. They scoured the city, asking around and following any leads they could find.

Finally, after weeks of searching, they received a tip that Docker was hiding out in a seedy hotel on the outskirts of town. Determined to get their money back, they headed over to the hotel and burst into Docker's room.

Docker was caught off guard and knew he was no match for the three gangsters. He begged for mercy, promising to pay them back as soon as possible.

RoyalL, ShottaS, and BiggyL considered his plea, but they knew they couldn't trust him. They demanded that he come up with a plan to pay them back immediately, or face the consequences.

Docker agreed, and with the help of the three gangsters, he was able to come up with a repayment plan that satisfied everyone. In the end, RoyalL, ShottaS, and BiggyL got their money back, and Docker learned his lesson about the importance of paying his debts on time.
