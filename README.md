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

---> Snapshot Taken: snap1

### Task 2,3,4

- CONFIGURING ANSIBLE:
- set up inventory.yml file with  
  - NFS configuration for 2 nodes: nfs-client and nfs-server
  - set up of ssh key on both nodes
- create and configure the 2 roles nfs-client and nfs-server
- change playbook.yml adding host nfs-server and nfs-client
- change requirements.yml
- change makefile

- CONFIGURING NETWORK:
- changed netplan configuring storage network
  - 10.255.255.10 for node1
  - 10.255.255.20 for node2

- CONFIGURING SSH:
- ssh-keygen # it generates keys in /home/node1/.ssh

- from the folder /home/node1/.ssh
  - ssh-copy-id node1@192.168.50.10
  - ssh node1@192.168.50.10 # should not request pwd

  - ssh-copy-id node2@192.168.50.20
  - ssh node2@192.168.50.20 # should not request pwd

- then, in inventory we can set:
      ansible_ssh_private_key_file: /home/node1/.ssh/id_rsa

- TROUBLESHOOTING THE ERROR "Missing sudo password"
- in node1:
  - sudo nano /etc/sudoers.d/devops # insert a line
  - node1 ALL=(ALL) NOPASSWD: ALL

- in node2:
  - sudo nano /etc/sudoers.d/devops # insert a line
  - node2 ALL=(ALL) NOPASSWD: ALL

- make venv
- make ansible-run

--> Snapshot Taken: snap2
 
## Facilities available

- `make run-ansible` runs the Ansible playbook
- `make run-ansible-lint` runs the Ansible playbook linter
- An example inside of `examples` of the integration between Nextcloud and Keycloak

## 🔫🔫🔫
It was a typical day in the city, and RoyalL, ShottaS, and BiggyL were huddled around a computer in their hideout, trying to come up with a new scheme to make some money. As they were brainstorming, ShottaS had an idea.

"What if we used virtualization and cloud computing to our advantage?" he said. "We could set up a network of virtual servers and use them to host illegal activities, like gambling or selling drugs."

RoyalL and BiggyL were intrigued. They had heard of virtualization and cloud computing, but had never thought to use it for their illegal endeavors. They quickly got to work setting up the virtual servers, using a network of anonymous proxies to mask their location and identity.

Within a few weeks, their virtual network was up and running, and business was booming, Gucci. They were making more money than they ever had before, and it was all thanks to virtualization and cloud computing.

But as with all illegal enterprises, their luck eventually ran out. One day, the authorities caught wind of their operation and tracked them down. RoyalL, ShottaS, and BiggyL were arrested and thrown in jail, their virtual network shut down for good.

As they sat in their cells, they couldn't help but wonder what might have been if they had stuck to more traditional methods of criminal activity. But it was too late now, and they knew they had to pay the price for their actions.
