#
# Settings
#
ANSIBLE_ARGS :=
ANSIBLE_PLAYBOOK := $(CURDIR)/playbook.yml
VENV_PATH := $(CURDIR)/venv
VENV_ACTIVATE_PATH := $(VENV_PATH)/bin/activate
STACKNAME = VCC_stack
#
# Ansible
#
.PHONY: ansible-prepare
ansible-prepare: update-venv
	. $(VENV_ACTIVATE_PATH) && ansible-galaxy collection install -r requirements.yml
	. $(VENV_ACTIVATE_PATH) && ansible-galaxy role install -r requirements.yml

.PHONY: ansible-ping
ansible-ping:
	ansible -m ping -i inventory.yml all

.PHONY: run-ansible
run-ansible: ansible-prepare
	. $(VENV_ACTIVATE_PATH) && ansible-playbook \
		--inventory inventory.yml \
		--ssh-common-args '-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' \
		$(ANSIBLE_ARGS) \
		$(ANSIBLE_PLAYBOOK)

.PHONY: run-ansible
run-ansible-lint: update-venv
	. $(VENV_ACTIVATE_PATH) && ansible-lint \
		--format rich \
		--profile production \
		$(ANSIBLE_PLAYBOOK)

.PHONY: add-role
add-role:
ifndef ROLE
	$(error Please set ROLE)
endif
	mkdir -p \
		roles/$(ROLE)/defaults \
		roles/$(ROLE)/files \
		roles/$(ROLE)/handlers \
		roles/$(ROLE)/meta \
		roles/$(ROLE)/tasks \
		roles/$(ROLE)/templates \
		roles/$(ROLE)/vars
	echo '---' > roles/$(ROLE)/defaults/main.yml
	echo '---' > roles/$(ROLE)/handlers/main.yml
	echo '---' > roles/$(ROLE)/meta/main.yml
	echo '---' > roles/$(ROLE)/tasks/main.yml
	echo '---' > roles/$(ROLE)/vars/main.yml

#
# Python
#
venv:
	python3 -m venv $(VENV_PATH)
	$(MAKE) update-venv

.PHONY: update-venv
update-venv: venv
	. $(VENV_ACTIVATE_PATH) && \
	pip install --upgrade pip && \
	pip install -r requirements.txt

#
# VCC
#
VCC_ROLES := \
	dashboard \
	database \
	docker \
	docker_swarm_manager \
	docker_swarm_worker \
	docker-commn \
	keycloak \
	logging \
	monitoring \
	nextcloud \
	nfs_client \
	nfs_server \
	prepare_stack \
	registry \
	registry-client \
	registry-tls-common
	
.PHONY: vcc-roles
vcc-roles:
	$(foreach role,$(VCC_ROLES),$(MAKE) add-role ROLE=$(role); )

SERVICES := \
	registry \
	registry-cache \
	VCC_stack_postgres \
	VCC_stack_keycloak \
	VCC_stack_nextcloud \
	VCC_stack_traefik \
	VCC_stack_fluent-bit \
	VCC_stack_loki \
	VCC_stack_cadvisor \
	VCC_stack_prometheus \
	VCC_stack_grafana

.PHONY: clean
clean: 
	sudo rm -r ./logs/* ; \
	sudo docker stack rm $(STACKNAME)
	
.PHONY: reset
reset: clean 
	sudo docker system prune --all; \
	sudo rm -r /data/* ; \
	sudo docker service rm registry \
	sudo docker service rm registry-cache

.PHONY: logs
logs:
	sudo cp -R /data/logs ./ ; \
	sudo chmod -R 777 ./logs ; \
	sudo docker service ls > logs/logs.txt ; \
	sudo docker service ps --no-trunc $(SERVICES) >> logs/logs.txt ; 

.PHONY: enter
enter:
ifndef id
	$(error Please set container id)
endif
	sudo docker exec -it $(id) /bin/sh

.PHONY: up
up:
	docker stack deploy --compose-file docker-compose.yml $(STACKNAME)

.PHONY: ssh_node1
ssh_node1:
	ssh node1@192.168.50.10

.PHONY: ssh_node2
ssh_node2:
	ssh node2@192.168.50.20

.PHONY: fluent_logs
fluent_logs:
ifndef id
	$(error Please set container id)
endif
	sudo docker logs $(id) 2>&1 | more

.PHONY: exec_fluent
exec_fluent:
ifndef cmd
	$(error Please enter command)
endif
	sudo docker run --rm -it fluent/fluent-bit:1.8.12-debug /fluent-bit/bin/fluent-bit -i exec -p 'command=$(cmd)' -o stdout