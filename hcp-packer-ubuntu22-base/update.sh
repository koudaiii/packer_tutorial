#!/bin/bash

GITDIR="/tmp/private-isu"
export DEBIAN_FRONTEND=noninteractive
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
echo "Updating packages..."
apt-get -qq -y update >/dev/null &&
    apt-get -qq -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade >/dev/null &&
    apt-get -qq -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install  ansible curl git unzip >/dev/null &&
    apt-get -qq -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install mysql-server >/dev/null &&
    apt-get -qq -y clean >/dev/null

rm -rf ${GITDIR}
git clone --depth=1 https://github.com/catatsuy/private-isu.git ${GITDIR}
cd ${GITDIR}/provisioning/
sed -i 's/isu-app/localhost ansible_connection=local/' hosts
sed -i 's/isu-bench/localhost ansible_connection=local/' hosts
ansible-galaxy collection install ansible.posix
ansible-playbook -i hosts image/ansible/playbooks.yml --skip-tags nodejs
ansible-playbook -i hosts bench/ansible/playbooks.yml
