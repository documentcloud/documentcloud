#!/bin/sh
# this script is run after a new preconfigured instance is provisioned

PATH=$PATH:/var/lib/gems/1.8/bin/

export DEBIAN_FRONTEND=noninteractive

# apt-get update
# apt-get -y upgrade

USERNAME=ubuntu

chown -R $USERNAME /home/$USERNAME
cd /home/$USERNAME/documentcloud
sudo -u $USERNAME git pull
bundle install
chown -R $USERNAME /home/$USERNAME

# TODO warm cache

# updatedb
