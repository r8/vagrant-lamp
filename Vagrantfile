# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # Set box configuration
  config.vm.box = "lucid32"
  config.vm.box_url = "http://files.vagrantup.com/lucid32.box"

  # Uncomment these lines to give the virtual machine more memory and "dual core cpu"
  #config.vm.customize ["modifyvm", :id, "--memory", 1024]
  #config.vm.customize ["modifyvm", :id, "--cpus", 2]

  # Forward MySql port on 33066, used for connecting admin-clients to localhost:33066
  config.vm.forward_port 3306, 33066

  # Set share folder permissions to 777 so that apache can write files
  config.vm.share_folder("v-root", "/vagrant", ".", :extra => 'dmode=777,fmode=666')

  # Assign this VM to a host-only network IP, allowing you to access it via the IP.
  config.vm.network :hostonly, "33.33.33.10"

  # Enable provisioning with chef solo, specifying a cookbooks path (relative
  # to this Vagrantfile), and adding some recipes and/or roles.
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.data_bags_path = "data_bags"
    chef.add_recipe "vagrant_main"

    chef.json.merge!({
      "mysql" => {
        "server_root_password" => "vagrant",
        "server_repl_password" => "vagrant",
        "server_debian_password" => "vagrant"
      },
      "oh_my_zsh" => {
        :users => [
          {
            :login => 'vagrant',
            :theme => 'blinks',
            :plugins => ['git', 'gem']
          }
        ]
      }
    })
  end
end
