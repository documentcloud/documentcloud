Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |v|
    v.name = "documentcloud"
    host = RbConfig::CONFIG['host_os']
    # Give VM 1/4 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else # sorry Windows folks, I can't help you
      cpus = 2
      mem = 1024
    end
    v.memory = mem
    v.cpus = cpus
    # https://www.virtualbox.org/ticket/13002
    # https://github.com/mitchellh/vagrant/issues/1807
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    v.customize ["modifyvm", :id, "--nictype1", "virtio"]
    #v.gui = true

  end
  config.vm.network :private_network, ip: "192.168.33.10"
  #################################################################################
  # Extract global username & database password for environment
  # TODO Extract environment
  # TODO Pass username to all child scripts
  #################################################################################
  require 'yaml'
  secrets = YAML.load_file('secrets/secrets.yml')['development']
  db_password = secrets['db_password']
  username = "ubuntu" # IF YOU WANT TO SETUP ENVIRONMENT WITH A DIFFERENT USERNAME, CHANGE IT HERE

  config.vm.synced_folder ".", "/home/#{username}/documentcloud", owner: username, group: username

  if db_password == nil || db_password == "" then throw "No database password found!  Be sure to import DocumentCloud Secrets" end
  if username == nil || username == "" then throw "No global username was set! Do this in the Vagrantfile by setting the username variable." end

  config.vm.provision "shell", args: ["#{username}", "#{db_password}"], inline: %Q{
  sudo apt-get -y update
  username=$1
  password=$2
  cd /home/$username
  sudo documentcloud/config/server/scripts/setup_common_dependencies.sh
  sudo su $username -c "sh /home/$username/documentcloud/config/server/scripts/setup_app.sh"
  sudo sh /home/$username/documentcloud/config/server/scripts/setup_database.sh development $password
  sudo sh /home/$username/documentcloud/config/server/scripts/setup_webserver.sh development
  sudo su - $username -c "cd /home/$username/documentcloud && rake db:fixtures:load"
  sudo su - $username -c "cd /home/$username/documentcloud && rake sunspot:solr:start"
  sudo su - root -c 'echo "127.0.0.1 dev.dcloud.org" >> /etc/hosts'
  sudo su - $username -c "cd /home/$username/documentcloud && crowd -c config/cloud_crowd/development -e development load_schema"
  sudo su - $username -c "cd /home/$username/documentcloud && rake development crowd:server:start"
  sudo su - $username -c "cd /home/$username/documentcloud && rake development crowd:node:start"
  }
end
