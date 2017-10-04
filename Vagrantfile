# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
MACHINE_HOSTNAME = "redmine.local"
#AutoNetwork.default_pool = '192.168.10.0/24'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "geerlingguy/centos7"
  config.vm.box_check_update = false
  #The box that was used that includes guest additions virtualbox 5.1.22
  #config.vm.box_version = "1.2.2" 

  if Vagrant.has_plugin?("vagrant-cachier")
      config.cache.scope = :box
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--name", MACHINE_HOSTNAME]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--memory", 512]
    vb.customize ["modifyvm", :id, "--cpus", 1]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.linked_clone=true
  end

  config.vm.define MACHINE_HOSTNAME do |machine|
    machine.vm.hostname = MACHINE_HOSTNAME
    machine.vm.network :public_network, ip: "172.16.27.196", netmask:"255.255.0.0"
  end

  # fix for bug centos vagrant 1.9.1 and plugin that lets interface down
  # https://github.com/mitchellh/vagrant/issues/8115
  config.vm.provision "shell", inline: "sudo /etc/init.d/network restart", run: "always"

  config.vm.provision "shell", inline: "bash /vagrant/provision.sh", privileged: false

end
