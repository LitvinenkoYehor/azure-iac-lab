#!/bin/bash
set -e

echo "1. Uruchamianie Terraform"
terraform apply -auto-approve

echo "2. Pobieranie IP maszyny wirtualnej"
VM_IP=$(terraform output -raw vm_public_ip)

echo "3. Oczekiwanie na uruchomienie portu SSH (22)"
while ! timeout 5 bash -c "echo >/dev/tcp/$VM_IP/22" 2>/dev/null; do
    echo "Maszyna sie uruchamia, ponowna proba za 5 sekund..."
    sleep 5
done

echo "4. Orkiestracja konfiguracji przez Ansible"
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "$VM_IP," -u azureuser --private-key ~/.ssh/id_rsa playbook.yml

echo "Sukces! Srodowisko gotowe pod adresem http://$VM_IP"
