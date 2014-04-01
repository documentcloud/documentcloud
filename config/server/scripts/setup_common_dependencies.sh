#!/bin/bash

USERNAME=ubuntu
RAILS_ENVIRONMENT=production

echo "deb http://apt.postgresql.org/pub/repos/apt/ saucy-pgdg main" > /etc/apt/sources.list.d/pgdg.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update

PACKAGES='
postgresql-client-9.3
libpq-dev
git-core
postfix
sqlite3
libsqlite3-dev
libcurl4-openssl-dev
graphicsmagick
pdftk
xpdf
libreoffice
libreoffice-common
libjpeg-dev
libtiff4-dev
libpng12-dev
libleptonica-dev
tesseract-ocr-dev
tesseract-ocr
libpcre3-dev
sysstat
libbz2-dev
'

RUBY_DEPENDENCIES='
build-essential
libffi-dev
libgdbm-dev
libncurses5-dev
libreadline-dev
libssl-dev
libyaml-dev
libxml2-dev
libxslt-dev
libexpat1-dev
zlib1g-dev
libzlib-ruby
libopenssl-ruby
ruby
ri
rdoc
irb
ruby-dev
rubygems
'

TESSERACT_LANGUAGES='
tesseract-ocr-osd
tesseract-ocr-eng
tesseract-ocr-chi-sim
tesseract-ocr-chi-tra
tesseract-ocr-fra
tesseract-ocr-dan
tesseract-ocr-deu
tesseract-ocr-jpn
tesseract-ocr-kor
tesseract-ocr-nld
tesseract-ocr-nor
tesseract-ocr-rus
tesseract-ocr-spa
tesseract-ocr-swe
tesseract-ocr-ukr
'

echo $PACKAGES $TESSERACT_LANGUAGES $RUBY_DEPENDENCIES | xargs apt-get install -y

# disable ssh dns to avoid long pause before login
grep -q '^UseDNS no' /etc/ssh/sshd_config || echo 'UseDNS no' >> /etc/ssh/sshd_config
/etc/init.d/ssh reload

# replace annoying motd with new one
rm /etc/motd
cat >/etc/motd <<'EOF'

______                                      _   _____ _                 _
|  _  \                                    | | /  __ \ |               | |
| | | |___   ___ _   _ _ __ ___   ___ _ __ | |_| /  \/ | ___  _   _  __| |
| | | / _ \ / __| | | | '_ ` _ \ / _ \ '_ \| __| |   | |/ _ \| | | |/ _` |
| |/ / (_) | (__| |_| | | | | | |  __/ | | | |_| \__/\ | (_) | |_| | (_| |
|___/ \___/ \___|\__,_|_| |_| |_|\___|_| |_|\__|\____/_|\___/ \__,_|\__,_|

EOF
uname -a | tee -a /etc/motd

# postfix configuration
perl -pi -e 's/smtpd_use_tls=yes/smtpd_use_tls=no/' /etc/postfix/main.cf

# Despite the fact that a system ruby has been installed via apt
# we'll use ruby-install and chruby to install a more recent ruby

installer_tmp="/home/ubuntu/downloads/"
mkdir -p $installer_tmp
cd $installer_tmp

#
# Make sure to check what the most recent version of ruby-install is.
#
ruby_install_version='0.4.1'
chruby_version='0.3.8'

wget -O ruby-install-$ruby_install_version.tar.gz https://github.com/postmodern/ruby-install/archive/v$ruby_install_version.tar.gz
tar -xzvf ruby-install-$ruby_install_version.tar.gz

wget -O chruby-$chruby_version.tar.gz https://github.com/postmodern/chruby/archive/v$chruby_version.tar.gz
tar -xzvf chruby-$chruby_version.tar.gz

# # OPTIONAL signature checking
# # Import Postmodern's key.
# wget https://raw.github.com/postmodern/postmodern.github.io/master/postmodern.asc
# gpg --import postmodern.asc
# 
# # Verify that ruby-install was signed by postmodern
# wget https://raw.github.com/postmodern/ruby-install/master/pkg/ruby-install-$ruby_install_version.tar.gz.asc
# gpg --verify ruby-install-$ruby_install_version.tar.gz.asc ruby-install-$ruby_install_version.tar.gz
# 
# # Verify that chruby was signed by postmodern
# wget https://raw.github.com/postmodern/chruby/master/pkg/chruby-$chruby_version.tar.gz.asc
# gpg --verify chruby-$chruby_version.tar.gz.asc chruby-$chruby_version.tar.gz

cd "$installer_tmp/ruby-install-$ruby_install_version/"
make install

cd "$installer_tmp/chruby-$chruby_version/"
make install

echo 'if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi' > /etc/profile.d/chruby.sh

source /etc/profile.d/chruby.sh

ruby-install ruby stable

rm -rf "$installer_tmp/ruby-install-$ruby_install_version/"
rm -rf "$installer_tmp/chruby-$chruby_version/"
