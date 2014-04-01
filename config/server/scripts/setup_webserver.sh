USERNAME=ubuntu
RAILS_ENVIRONMENT=production

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo apt-get install apt-transport-https ca-certificates

echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger saucy main" | sudo tee /etc/apt/sources.list.d/passenger.list

sudo apt-get update

sudo apt-get install -y nginx-extras passenger
# crash-watch gdb libc6-dbg libev4 liblua5.1-0 libperl5.14 nginx-common nginx-extras passenger passenger-dev passenger-doc ruby-daemon-controller ruby-rack

# Config files for nginx installed via apt-get are located in /etc/nginx

test -e pixel-ping || sudo -u $USERNAME git clone git@github.com:documentcloud/pixel-ping.git pixel-ping

