#!/bin/bash
# first boot the official EBS root Canonical Ubuntu 9.10 Karmic Image, ami-6743ae0e (32bit) or ami-7d43ae14 (64bit)
# TODO break this up into smaller modules

test $USER = 'root' || { echo run this as root >&2; exit 1; }

USERNAME=ubuntu
RAILS_ENVIRONMENT=production

grep -q multiverse /etc/apt/sources.list || cat <<EOF | tee /etc/apt/sources.list
deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/ karmic main universe multiverse
deb-src http://us-east-1.ec2.archive.ubuntu.com/ubuntu/ karmic main universe
deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/ karmic-updates main universe multiverse
deb-src http://us-east-1.ec2.archive.ubuntu.com/ubuntu/ karmic-updates main universe
deb http://security.ubuntu.com/ubuntu karmic-security main universe multiverse
deb-src http://security.ubuntu.com/ubuntu karmic-security main universe
EOF

add-apt-repository "deb http://archive.canonical.com/ lucid partner"
add-apt-repository ppa:pitti/postgresql

apt-get update
apt-get -y upgrade

# sun java wants you to hold its hand
export DEBIAN_FRONTEND=readline
yes yes| apt-get install -y sun-java6-bin
export DEBIAN_FRONTEND=noninteractive

PACKAGES='
build-essential
postgresql-9.0
postgresql-client-9.0
postgresql-contrib-9.0
libpq-dev
git-core
mercurial
scons
libexpat1-dev
libxml2-dev
libxslt-dev
postfix
ruby
ri
rdoc
irb
ruby1.8-dev
zlib1g-dev
libzlib-ruby
sqlite3
libsqlite3-dev
libcurl4-dev
checkinstall
libbz2-dev
graphicsmagick
pdftk
xpdf
libitext-java
openoffice.org
openoffice.org-java-common
libtiff4-dev
libpng12-dev
libjpeg62-dev
libleptonica-dev
tesseract-ocr-dev
tesseract-ocr-eng
xfsprogs
libpcre3-dev
lzop
sysstat
libopenssl-ruby'

echo $PACKAGES | xargs apt-get install -y

GEMS_VERSION=1.7.2
gem --version 2>/dev/null | grep -q $GEMS_VERSION || {
  cd /tmp
  wget http://production.cf.rubygems.org/rubygems/rubygems-$GEMS_VERSION.tgz
  tar xzvf rubygems-$GEMS_VERSION.tgz
  ruby rubygems-$GEMS_VERSION/setup.rb
  ln -s /usr/bin/gem1.8 /usr/local/bin/gem
  rm -rf rubygems-$GEMS_VERSION*
}

GEMS='pg sqlite3 passenger sinatra right_aws fastercsv sanitize
rest-client rack bcrypt-ruby rdiscount rubyzip libxml-ruby nokogiri json hpricot
calais curb daemons cloud-crowd yui-compressor jammit docsplit sunspot sunspot_rails'

echo $GEMS | xargs gem install --no-ri --no-rdoc

gem install rails --no-ri --no-rdoc --version 2.3.11

cd /home/$USERNAME

# approve github ssh host key
grep -q github .ssh/known_hosts 2>/dev/null || ssh-keyscan -t rsa github.com > .ssh/known_hosts

# [copy over the secrets directory].

chown -R $USERNAME .
test -e documentcloud || sudo -u $USERNAME git clone git@github.com:documentcloud/documentcloud.git documentcloud
cd /home/$USERNAME/documentcloud
cp config/server/gitconfig.conf .gitconfig
rake gems:install

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

# setup dummy postgres environment so that you can verify rails is working
cp config/server/postgres/pg_hba.conf  /etc/postgresql/9.0/main/pg_hba.conf
/etc/init.d/postgresql reload
sudo -u postgres createuser -s ubuntu
sudo -u postgres createuser -s documentcloud
sudo -u postgres psql -c "alter user documentcloud password 'YOUR_DB_PASSWORD_GOES_HERE' "
sudo -u postgres createdb dcloud_$RAILS_ENVIRONMENT
cd /home/$USERNAME/documentcloud
sudo -u postgres psql -f db/development_structure.sql dcloud_$RAILS_ENVIRONMENT 2>&1|grep ERROR
# rake $RAILS_ENVIRONMENT db:migrate

# nginx
test -e /usr/local/nginx || /usr/bin/passenger-install-nginx-module --auto --auto-download \
    --prefix /usr/local/nginx --extra-configure-flags='--with-http_gzip_static_module --with-http_ssl_module --with-http_stub_status_module'
LINE='export PATH=$PATH:/usr/local/nginx/sbin'
grep -q "$LINE" .bashrc 2>/dev/null || echo "$LINE" >> .bashrc
mkdir -p /usr/local/nginx/conf/sites-enabled /var/log/nginx/
mkdir -p /var/log/nginx
cp config/server/nginx/nginx.conf /usr/local/nginx/conf/
cp config/server/nginx/$RAILS_ENVIRONMENT.conf /usr/local/nginx/conf/sites-enabled/
# TODO nginx configuration is not rock solid
cp config/server/nginx/nginx.init /etc/init.d/nginx
update-rc.d nginx defaults
/etc/init.d/nginx start

# TODO configure cloud-crowd

chown -R $USERNAME /home/$USERNAME
updatedb &
