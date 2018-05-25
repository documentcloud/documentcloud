#!/bin/bash

#################################
# SCRIPT SETUP
#################################

# exit the script if any of the commands fail.
# further discussion: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
echo BEGINNING APT DEPENDENCIES

set -e

# This script needs to be run as root for permission purposes
#test $USER = 'root' || { echo run this as root >&2; exit 1; }
# but the user we actually care about is the login user.
#LOGINUSER=$(logname)      # login user is ubuntu for a vanilla ubuntu installation.
#USERNAME=${1:-$LOGINUSER} # but this can be overridden by passing a username as the first argument.
DISTRO_NAME=jessie

#################################
# INSTALL SYSTEM DEPENDENCIES
#################################

# Make sure that apt-get doesn't attempt to load up any guis.
DEBIAN_FRONTEND=noninteractive

# Always make sure that we have up to date postgres packages by adding their apt repository.
echo "deb http://apt.postgresql.org/pub/repos/apt/ $DISTRO_NAME-pgdg main" > /etc/apt/sources.list.d/pgdg.list

echo 'wgetting key'
# and make sure that we have the key to verify their repository
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

echo 'updating apt'
apt-get update

# List all the common system dependencies that all of our machines need.
PACKAGES='
build-essential
postgresql-client-9.6
libpq-dev
git-core
sqlite3
libsqlite3-dev
libcurl4-openssl-dev
libpcre3-dev
sysstat
libbz2-dev
make
ntp
'

# Fonts to support Chinese, Japanese, and Korean character sets
FONT_PACKAGES='
ttf-wqy-microhei
ttf-wqy-zenhei
fonts-ipafont-gothic
fonts-ipafont-mincho
fonts-nanum
ttf-baekmuk
'

echo 'installing...'
# install all system dependencies
echo $PACKAGES $FONT_PACKAGES | xargs apt-get install -y

# turn off rdoc/ri generation for gems
echo 'gem: --no-document' > ~/.gemrc

#################################
# SYSTEM CONFIG
#################################

# CS 7.6.15 disabling for development purposes
# disable ssh dns to avoid long pause before login
#grep -q '^UseDNS no' /etc/ssh/sshd_config || echo 'UseDNS no' >> /etc/ssh/sshd_config
#service ssh reload

# postfix configuration
#perl -pi -e 's/smtpd_use_tls=yes/smtpd_use_tls=no/' /etc/postfix/main.cf

# replace annoying motd with new one
test -e /etc/motd && rm /etc/motd
cat >/etc/motd <<'EOF'

______                                      _   _____ _                 _
|  _  \                                    | | /  __ \ |               | |
| | | |___   ___ _   _ _ __ ___   ___ _ __ | |_| /  \/ | ___  _   _  __| |
| | | / _ \ / __| | | | '_ ` _ \ / _ \ '_ \| __| |   | |/ _ \| | | |/ _` |
| |/ / (_) | (__| |_| | | | | | |  __/ | | | |_| \__/\ | (_) | |_| | (_| |
|___/ \___/ \___|\__,_|_| |_| |_|\___|_| |_|\__|\____/_|\___/ \__,_|\__,_|

EOF
uname -a | tee -a /etc/motd

echo COMMON DEPENDENCY SETUP COMPLETED SUCCESSFULLY
