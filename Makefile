# Переменные
VM_NAME := ubuntu-vm
SSH_KEY_PATH := $(HOME)/.ssh/id_rsa.pub
IP = `multipass info $(VM_NAME) | grep IPv4 | awk '{print $$2}'`
UBUNTU_MACHINE = ubuntu@$(IP)
NIXOS_MACHINE = root@$(IP)

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

# Получение IP-адреса виртуальной машины
.PHONY: get_ip
get-ip:
	@echo "IP-адрес виртуальной машины:"
	@multipass info $(VM_NAME) | grep IPv4 | awk '{print $$2}'

# Очистка (удаление виртуальной машины)
.PHONY: clean
clean:
	@echo "Удаление виртуальной машины..."
	multipass delete $(VM_NAME)
	multipass purge

shell/ubuntu:
	multipass shell $(VM_NAME)

shell/nixos:
	ssh $(NIXOS_MACHINE)

run-nixos-anywhere/dryrun:
	nix run github:nix-community/nixos-anywhere -- --flake './nixos-anywhere-examples#hetzner-cloud' --vm-test

run-nixos-anywhere/install:
	ssh-keygen -f ~/.ssh/known_hosts -R "$(IP)"
	nix run github:nix-community/nixos-anywhere -- --flake './nixos-anywhere-examples#hetzner-cloud' $(UBUNTU_MACHINE)

run-nixos-anywhere/switch:
	ssh-keygen -f ~/.ssh/known_hosts -R "$(IP)"
	# nix run github:nix-community/nixos-anywhere -- --flake './nixos-anywhere-examples#hetzner-cloud' root@$(IP)
	nixos-rebuild switch --flake "./nixos-anywhere-examples#hetzner-cloud" --target-host "root@$(IP)"

