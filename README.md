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
