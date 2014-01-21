#!/bin/sh
# This script launches a production CloudCrowd node.

PATH=$PATH:/var/lib/gems/1.8/bin/

export DEBIAN_FRONTEND=noninteractive

USERNAME=ubuntu

su -c "curl http://169.254.169.254/latest/meta-data/hostname | sudo xargs hostname"
cd /home/$USERNAME/documentcloud
su $USERNAME -c "rake production crowd:node:start"
