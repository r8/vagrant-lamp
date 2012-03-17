# -*- mode: ruby -*-
# vi: set ft=ruby :

# Upgrade chef before provisioning
class ChefSolo0104Provisioner < Vagrant::Provisioners::ChefSolo
  def provision!
    env[:ui].info "Installing chef 0.10.4"
    env[:vm].channel.sudo("gem install chef -v '= 0.10.4' --no-ri --no-rdoc")
    super
  end
end

Vagrant::Config.run do |config|
  # Set box configuration
  config.vm.box = "lucid32"
  #config.vm.box_url = "http://files.vagrantup.com/lucid32.box"

  # Assign this VM to a host-only network IP, allowing you to access it via the IP.
  config.vm.network :hostonly, "33.33.33.10"

  # Enable provisioning with chef solo, specifying a cookbooks path (relative
  # to this Vagrantfile), and adding some recipes and/or roles.
  config.vm.provision ChefSolo0104Provisioner do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.data_bags_path = "data_bags"
    chef.add_recipe "vagrant_main"

    chef.json.merge!({
      "mysql" => {
        "server_root_password" => "vagrant"
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
