#!/bin/sh
# This script launches a production CloudCrowd node.

PATH=$PATH:/var/lib/gems/1.8/bin/

export DEBIAN_FRONTEND=noninteractive

USERNAME=ubuntu

cd /home/$USERNAME/document-cloud
su $USERNAME -c "rake production crowd:node:start"
