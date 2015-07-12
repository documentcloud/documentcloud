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
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--nictype1", "virtio"]
    #v.gui = true
  end
  config.vm.network :private_network, ip: "192.168.33.10"
  #config.vm.synced_folder '.', '/vagrant', nfs: true
  config.vm.synced_folder ".", "/home/ubuntu/documentcloud", owner: "ubuntu", group: "ubuntu"
  config.vm.provision "shell", inline: %Q{
  sudo apt-get -y update
  cd /home/ubuntu
  ln -s /vagrant documentcloud
  sudo documentcloud/config/server/scripts/setup_common_dependencies.sh
  }
end