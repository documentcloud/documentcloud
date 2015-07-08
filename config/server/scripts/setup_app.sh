#!/bin/bash

# approve github ssh host key
grep -q github .ssh/known_hosts 2>/dev/null || ssh-keyscan -t rsa github.com > .ssh/known_hosts

# Make sure you have your github keys authorized, installed, and chmod to 600!

USERNAME=ubuntu
RAILS_ENVIRONMENT=${RAILS_ENV:-"$ENV_ARG"} 

# Install pdfium https://github.com/documentcloud/pdfshaver
# TODO allow user to specifiy pdfium version
cd /home/$USERNAME && wget 'http://s3.documentcloud.org.s3.amazonaws.com/pdfium/libpdfium-dev_0.1%2Bgit20150311-1_amd64.deb'
sudo dpkg -i libpdfium-dev_0.1+git20150311-1_amd64.deb
sudo apt-get install libfreeimage-dev libfreetype6-dev

test -e documentcloud || git clone git@github.com:documentcloud/documentcloud.git documentcloud
cd documentcloud
gem install bundler
./bin/bundle install

# Don't forget to download your secrets file into documentcloud/secrets!

#./bin/rails runner -e production 'puts "You already have #{Document.count} documents"'

# if you would like to use git hooks to automatically bundle the app's gem dependencies:
# sudo ln -s /home/$USERNAME/documentcloud/config/server/files/git-post-merge.sh /home/$USERNAME/documentcloud/.git/hooks/post-merge