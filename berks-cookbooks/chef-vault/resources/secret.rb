require 'chef-vault'

resource_name :chef_vault_secret

property :id, String, name_property: true
property :data_bag, String, required: true, desired_state: false
property :admins, [String, Array], required: true, desired_state: false
property :clients, [String, Array], desired_state: false
property :search, String, default: '*:*', desired_state: false
property :raw_data, [Hash, Mash], default: {}
property :environment, [String, NilClass], default: nil, nillable: true, desired_state: false

load_current_value do
  begin
    item = ChefVault::Item.load(data_bag, id)
    raw_data item.raw_data
    clients item.get_clients
    admins item.get_admins
    search item.search
  rescue ChefVault::Exceptions::KeysNotFound
    current_value_does_not_exist!
  rescue Net::HTTPServerException => e
    current_value_does_not_exist! if e.response_code == '404'
  end
end

default_action :create

action :create do
  converge_if_changed do
    item = ChefVault::Item.new(new_resource.data_bag, new_resource.id)

    Chef::Log.debug("#{new_resource.id} environment: '#{new_resource.environment}'")
    item.raw_data = if new_resource.environment.nil?
                      new_resource.raw_data.merge('id' => new_resource.id)
                    else
                      { 'id' => new_resource.id, new_resource.environment => new_resource.raw_data }
                    end

    Chef::Log.debug("#{new_resource.id} search query: '#{new_resource.search}'")
    item.search(new_resource.search)
    Chef::Log.debug("#{new_resource.id} clients: '#{new_resource.clients}'")
    item.clients([new_resource.clients].flatten.join(',')) unless new_resource.clients.nil?
    Chef::Log.debug("#{new_resource.id} admins (users): '#{new_resource.admins}'")
    item.admins([new_resource.admins].flatten.join(','))
    item.save
  end
end

action :create_if_missing do
  action_create if current_value.nil?
end

action :delete do
  converge_by("remove #{new_resource.id} and #{new_resource.id}_keys from #{new_resource.data_bag}") do
    chef_data_bag_item new_resource.id do
      data_bag new_resource.data_bag
      action :delete
    end

    chef_data_bag_item [new_resource.id, 'keys'].join('_') do
      data_bag new_resource.data_bag
      action :delete
    end
  end
end
