#!/bin/bash

# exit the script if any of the commands fail.
# further discussion: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
set -e

# Do not run script as root.  Will fail installing pdfium if you do...
test $USER != 'root' || { echo do NOT run as root >&2; exit 1; }

USERNAME=ubuntu
CLI_ARG=$1
RAILS_ENVIRONMENT=${CLI_ARG:-"$RAILS_ENV"} 


# Install pdfium https://github.com/documentcloud/pdfshaver
# TODO Should we allow user to specifiy pdfium version?
cd /home/$USERNAME && sudo wget 'http://s3.documentcloud.org.s3.amazonaws.com/pdfium/libpdfium-dev_0.1%2Bgit20150311-1_amd64.deb'
sudo dpkg -i libpdfium-dev_0.1+git20150311-1_amd64.deb
sudo apt-get install libfreeimage-dev libfreetype6-dev

# approve github ssh host key
# run as ubuntu user so that we don't need to change permissions
# Make sure you have your github keys authorized, installed, and chmod to 600!
sudo su -l ubuntu <<EOF
sudo grep -q github /home/$USERNAME/.ssh/known_hosts 2>/dev/null || sudo ssh-keyscan -t rsa github.com > /home/$USERNAME/.ssh/known_hosts
test -e /home/$USERNAME/documentcloud || git clone git@github.com:documentcloud/documentcloud.git documentcloud
EOF

# Install bundler and install gems
sudo su -l ubuntu <<EOF
cd /home/$USERNAME/documentcloud
gem install bundler
bundle
EOF

# # Set password in environment.
# sudo su -l ubuntu <<EOF
# cd /home/ubuntu/documentcloud && rails runner "ENV['PASSWORD']='hi'"
# EOF


# Don't forget to download your secrets file into documentcloud/secrets!

#./bin/rails runner -e production 'puts "You already have #{Document.count} documents"'

# if you would like to use git hooks to automatically bundle the app's gem dependencies:
# sudo ln -s /home/$USERNAME/documentcloud/config/server/files/git-post-merge.sh /home/$USERNAME/documentcloud/.git/hooks/post-merge