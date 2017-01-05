#!/bin/bash
# My first script

echo "Vagrant Fixes"

# 1) Uninstall nginx

sudo apt-get remove nginx nginx-common

# 2) Install nginx
# https://www.phusionpassenger.com/library/install/nginx/install/oss/trusty/ or 

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger + Nginx
N | sudo apt-get install -y nginx-extras passenger
