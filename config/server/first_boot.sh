#!/bin/sh
# this script is run after a new instance is provisioned

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y upgrade
apt-get -y install emacs23-nox lzop sysstat xfsprogs

USERNAME=ubuntu
sudo -u postgres createuser -s $USERNAME

# approve github ssh key
ssh-keyscan -t rsa  github.com >> /home/$USERNAME/.ssh/known_hosts
cd /home/$USERNAME/document-cloud
git pull
/var/lib/gems/1.8/bin/rake gems:install

chown -R $USERNAME /home/$USERNAME

updatedb &

grep -q '^UseDNS no' $f || echo 'UseDNS no' >> /etc/ssh/sshd_config
/etc/init.d/ssh reload
