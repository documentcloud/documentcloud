Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |v|
    v.name = "documentcloud"
    v.memory = 2048
  end
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.provision "shell", inline: %Q{
  sudo apt-get -y update
  cd /home/vagrant
  ln -s /vagrant documentcloud
  sudo documentcloud/config/server/scripts/setup_common_dependencies.sh
  }
end