#!/bin/bash

# exit the script if any of the commands fail.
# further discussion: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
set -e

# This script needs to be run as root for permission purposes
test $USER = 'root' || { echo run this as root >&2; exit 1; }

USERNAME=ubuntu
CLI_ARG=$1
RAILS_ENVIRONMENT=${CLI_ARG:-"$RAILS_ENV"}

# Set the RAILS ENV
#source ~/.bashrc && [ -z "$RAILS_ENV" ] && echo "export RAILS_ENV=$RAILS_ENVIRONMENT" >> ~/.bashrc

# Make sure we have env set
# If environment is not set exit script.  Make Command line priority.
if [ ! -n "$RAILS_ENVIRONMENT" ]; then 
  echo "environment must be set in RAILS_ENV or passed as first argument. CLI will be priority" >&2; exit 1;
fi
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
apt-get install apt-transport-https ca-certificates -y

echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" | tee /etc/apt/sources.list.d/passenger.list
gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -

apt-get update

apt-get install nginx-extras passenger -y
# crash-watch gdb libc6-dbg libev4 liblua5.1-0 libperl5.14 nginx-common nginx-extras passenger passenger-dev passenger-doc ruby-daemon-controller ruby-rack

apt-get install nodejs nodejs-dev npm -y
ln -sf /usr/bin/nodejs /usr/bin/node

npm install -g coffee-script

# Config files for nginx installed via apt-get are located in /etc/nginx

cd /home/$USERNAME

test -e pixel-ping || su -c "git clone git://github.com/documentcloud/pixel-ping.git pixel-ping" $USERNAME

#cd /home/$USERNAME/documentcloud

test -e /etc/nginx/nginx.conf && mv /etc/nginx/nginx.conf /etc/nginx/nginx.default.conf
test -e /etc/nginx/sites-enabled/default && rm /etc/nginx/sites-enabled/default

# Needed to remove variable expansion using { } as it was causing script to fail. 
sudo cp /home/$USERNAME/documentcloud/config/server/files/nginx/nginx.conf /etc/nginx/
sudo cp /home/$USERNAME/documentcloud/config/server/files/nginx/documentcloud.conf /etc/nginx/
sudo cp /home/$USERNAME/documentcloud/config/server/files/nginx/passenger.conf /etc/nginx/
sudo cp /home/$USERNAME/documentcloud/config/server/files/nginx/staging.conf /etc/nginx/sites-available/
sudo cp /home/$USERNAME/documentcloud/config/server/files/nginx/production.conf /etc/nginx/sites-available/
sudo cp /home/$USERNAME/documentcloud/config/server/files/nginx/development.conf /etc/nginx/sites-available/

ln -fs /etc/nginx/sites-available/$RAILS_ENVIRONMENT.conf /etc/nginx/sites-enabled/documentcloud-$RAILS_ENVIRONMENT.conf
ln -fs /var/log/nginx /etc/nginx/logs

! test -e /usr/share/nginx/logs && mkdir /usr/share/nginx/logs
! test -e /home/$USERNAME/documentcloud/log && mkdir /home/$USERNAME/documentcloud/log
# touch -f /home/$USERNAME/documentcloud/log/pixel_ping.pid
# touch -f /home/$USERNAME/documentcloud/log/pixel_ping.log

sudo service nginx restart

sudo su -l $USERNAME <<EOF
echo $RAILS_ENVIRONMENT
cd /home/$USERNAME/documentcloud && rake $RAILS_ENVIRONMENT ping:start
EOF

# Rails command for vagrant
echo "
function vrails() {
 sudo su -l ubuntu -c \"cd /home/ubuntu/documentcloud && rails \$1 \$2 \$3\"
}
" >> /home/vagrant/.bashrc

# Rake commands for vagrant
echo "
function vrake() {
  sudo su -l ubuntu -c \"cd /home/ubuntu/documentcloud && rake \$1 \$2 \$3\"
}
" >> /home/vagrant/.bashrc

# Bundler access interface for vagrant
echo "
function vbundle() {
 sudo su -l ubuntu -c \"cd /home/ubuntu/documentcloud && bundle \$1 \$2 \$3\"
}
" >> /home/vagrant/.bashrc


echo WEBSERVER SETUP COMPLETED SUCCESSFULLY
