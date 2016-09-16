#!/bin/bash

# exit the script if any of the commands fail.
# further discussion: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
echo BEGINNING WEBSERVER SETUP

set -e

# This script needs to be run as root for permission purposes
test $USER = 'root' || { echo run this as root >&2; exit 1; }
# but the user we actually care about is the login user.
LOGINUSER=$(logname)      # login user is ubuntu for a vanilla ubuntu installation.
USERNAME=${2:-$LOGINUSER} # but this can be overridden by passing a username as the second argument.
DISTRO_NAME=xenial

RAILS_ENVIRONMENT=${1:-"$RAILS_ENV"}

# Make sure we have env set
# If environment is not set exit script.  Make Command line priority.
if [ ! -n "$RAILS_ENVIRONMENT" ]; then 
  echo "environment must be set in RAILS_ENV or passed as first argument. CLI will be priority" >&2; exit 1;
fi

# update certificates
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
apt-get install apt-transport-https ca-certificates -y

# Add Passenger's apt server
echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger $DISTRO_NAME main" | tee /etc/apt/sources.list.d/passenger.list
gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -

# fetch metadata so that we can find the passenger package
apt update

# and install it.
apt install nginx-extras passenger -y

# also, install node and coffeescript, so that we can install pixel-ping and bower.
apt install nodejs -y
npm install -g coffee-script

# clone pixel-ping
cd /home/$USERNAME
test -e pixel-ping || su -c "git clone git://github.com/documentcloud/pixel-ping.git pixel-ping" $USERNAME

# Config files for nginx installed via apt-get are located in /etc/nginx
#
# first move the existing config files out of the way.
test -e /etc/nginx/nginx.conf && mv /etc/nginx/nginx.conf /etc/nginx/nginx.default.conf
test -e /etc/nginx/sites-enabled/default && rm /etc/nginx/sites-enabled/default

# then copy our nginx configuration into the system directory
cd /home/$USERNAME/documentcloud
sudo cp config/server/files/nginx/*.conf                 /etc/nginx/
sudo cp -r config/server/files/nginx/documentcloud       /etc/nginx/documentcloud
sudo cp config/server/files/nginx/sites-available/*.conf /etc/nginx/sites-available/

# and link up the environment specific config file and the server configuration.
ln -fs /etc/nginx/documentcloud/env/$RAILS_ENVIRONMENT.conf        /etc/nginx/documentcloud/env.conf
ln -fs /etc/nginx/sites-available/documentcloud.conf               /etc/nginx/sites-enabled/documentcloud.conf
ln -fs /etc/nginx/documentcloud/cache_env/$RAILS_ENVIRONMENT.conf  /etc/nginx/documentcloud/cache_env.conf
ln -fs /etc/nginx/sites-available/documentcloud_cache.conf         /etc/nginx/sites-enabled/documentcloud_cache.conf
ln -fs /var/log/nginx                                              /etc/nginx/logs

! test -e /usr/share/nginx/logs && mkdir /usr/share/nginx/logs
! test -e /home/$USERNAME/documentcloud/log && mkdir /home/$USERNAME/documentcloud/log

# and restart nginx
sudo service nginx restart

sudo su -l $USERNAME <<EOF
  echo $RAILS_ENVIRONMENT
  cd /home/$USERNAME/documentcloud && rake $RAILS_ENVIRONMENT ping:start
EOF

echo WEBSERVER SETUP COMPLETED SUCCESSFULLY
