Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |v|
    v.name = "documentcloud"
    v.memory = 2048
    # https://www.virtualbox.org/ticket/13002
    # https://github.com/mitchellh/vagrant/issues/1807
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--nictype1", "virtio"]
    v.gui = true
  end
  config.vm.network :private_network, ip: "192.168.33.10"
  #config.vm.synced_folder '.', '/vagrant', nfs: true
  config.vm.provision "shell", inline: %Q{
  sudo apt-get -y update
  cd /home/ubuntu
  ln -s /vagrant documentcloud
  sudo documentcloud/config/server/scripts/setup_common_dependencies.sh
  }
end