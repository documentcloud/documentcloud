#!/bin/bash

# exit the script if any of the commands fail.
# further discussion: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
set -e

# This script needs to be run as root for permission purposes
test $USER = 'root' || { echo run this as root >&2; exit 1; }

USERNAME=ubuntu
RAILS_ENVIRONMENT=production

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
apt-get install apt-transport-https ca-certificates

echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" | tee /etc/apt/sources.list.d/passenger.list

apt-get update

apt-get install nginx-extras passenger -y
# crash-watch gdb libc6-dbg libev4 liblua5.1-0 libperl5.14 nginx-common nginx-extras passenger passenger-dev passenger-doc ruby-daemon-controller ruby-rack

apt-get install nodejs nodejs-dev npm -y
ln -sf /usr/bin/nodejs /usr/bin/node

npm install -g coffee-script

# Config files for nginx installed via apt-get are located in /etc/nginx

cd /home/$USERNAME

test -e pixel-ping || su -c "git clone git://github.com/documentcloud/pixel-ping.git pixel-ping" $USERNAME

cd /home/$USERNAME/documentcloud

mv /etc/nginx/nginx.conf /etc/nginx/nginx.default.conf

cp config/server/files/nginx/{nginx,documentcloud,staging,passenger}.conf /etc/nginx/
