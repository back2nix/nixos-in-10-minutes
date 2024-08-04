# Переменные
VM_NAME := ubuntu-vm
SSH_KEY_PATH := $(HOME)/.ssh/id_rsa.pub

# Цель по умолчанию
# .PHONY: all
# all: create_vm setup_ssh

# Создание виртуальной машины
.PHONY: create_vm
create_vm:
	@echo "Создание виртуальной машины Ubuntu..."
	multipass launch --name $(VM_NAME)

# Настройка SSH
.PHONY: setup_ssh
setup_ssh:
	@echo "Установка SSH-сервера и копирование SSH-ключа..."
	multipass exec $(VM_NAME) -- sudo apt-get update
	multipass exec $(VM_NAME) -- sudo apt-get install -y openssh-server
	multipass exec $(VM_NAME) -- sudo systemctl enable ssh
	multipass exec $(VM_NAME) -- sudo systemctl start ssh
	multipass transfer $(SSH_KEY_PATH) $(VM_NAME):/home/ubuntu/id_rsa.pub
	multipass exec $(VM_NAME) -- sudo systemctl restart ssh
	multipass exec $(VM_NAME) -- mkdir -p /home/ubuntu/.ssh
	multipass exec $(VM_NAME) -- touch /home/ubuntu/.ssh/authorized_keys
	multipass exec $(VM_NAME) -- bash -c 'cat /home/ubuntu/id_rsa.pub >> ~/.ssh/authorized_keys'
	multipass exec $(VM_NAME) -- chmod 600 /home/ubuntu/.ssh/authorized_keys
	multipass exec $(VM_NAME) -- rm /home/ubuntu/id_rsa.pub
	@echo "IP-адрес виртуальной машины:"
	@multipass info $(VM_NAME) | grep IPv4 | awk '{print $$2}'
	@multipass info ubuntu-vm | grep IPv4 | awk '{print $$2}'



shell:
	multipass shell $(VM_NAME)

# Получение IP-адреса виртуальной машины
.PHONY: get_ip
get_ip:
	@echo "IP-адрес виртуальной машины:"
	@multipass info $(VM_NAME) | grep IPv4 | awk '{print $$2}'

# Очистка (удаление виртуальной машины)
.PHONY: clean
clean:
	@echo "Удаление виртуальной машины..."
	multipass delete $(VM_NAME)
	multipass purge

IP = `multipass info $(VM_NAME) | grep IPv4 | awk '{print $$2}'`
machine = ubuntu@$(IP)

run-nixos-anywhere/dryrun:
	nix run github:nix-community/nixos-anywhere -- --flake './nixos-anywhere-examples#hetzner-cloud' --vm-test

run-nixos-anywhere/install:
	ssh-keygen -f ~/.ssh/known_hosts -R "$(IP)"
	nix run github:nix-community/nixos-anywhere -- --flake './nixos-anywhere-examples#hetzner-cloud' $(machine)

run-nixos-anywhere/switch:
	ssh-keygen -f ~/.ssh/known_hosts -R "$(IP)"
	# nix run github:nix-community/nixos-anywhere -- --flake './nixos-anywhere-examples#hetzner-cloud' root@$(IP)
	nixos-rebuild switch --flake "./nixos-anywhere-examples#hetzner-cloud" --target-host "root@$(IP)"

get-ip:
	@echo "IPv4 address:"
	@docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nixos-test
	@echo "\nIPv6 address:"
	@docker inspect -f '{{range .NetworkSettings.Networks}}{{.GlobalIPv6Address}}{{end}}' nixos-test

# copy-ssh-key:
# 	@read -p "Enter the path to your public SSH key: " keypath; \
# 	cp $$keypath ssh_key.pub
