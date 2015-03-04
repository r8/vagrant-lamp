# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "chef/ubuntu-14.04"

  # Set Chef version for Omnibus
  config.omnibus.chef_version = :latest

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  # Forward MySql port on 33066, used for connecting admin-clients to localhost:33066
  config.vm.network :forwarded_port, guest: 3306, host: 33066
  # Forward http port on 8080, used for connecting web browsers to localhost:8080
  config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "192.168.33.10"

  # Set share folder permissions to 777 so that apache can write files
  config.vm.synced_folder ".", "/vagrant", mount_options: ['dmode=777','fmode=666']

  # Provider-specific configuration so you can fine-tune VirtualBox for Vagrant.
  # These expose provider-specific options.
  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  config.vm.provision :chef_zero do |chef|
    chef.cookbooks_path = ["berks-cookbooks", "cookbooks"] 
    chef.data_bags_path = "data_bags"

    # List of recipes to run
    chef.add_recipe "vagrant_main"
    #chef.add_recipe "vagrant_main::wordpress"
    #chef.add_recipe "vagrant_main::drupal"
    #chef.add_recipe "vagrant_main::magento"
    #chef.add_recipe "vagrant_main::nodejs"
  end
end
