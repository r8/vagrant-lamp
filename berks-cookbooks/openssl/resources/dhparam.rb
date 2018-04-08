include OpenSSLCookbook::Helpers

property :path,        String, name_property: true
property :key_length,  equal_to: [1024, 2048, 4096, 8192], default: 2048
property :generator,   equal_to: [2, 5], default: 2
property :owner,       String, default: 'root'
property :group,       String, default: node['root_group']
property :mode,        [Integer, String], default: '0640'

action :create do
  unless dhparam_pem_valid?(new_resource.path)
    converge_by("Create a dhparam file #{new_resource.path}") do
      dhparam_content = gen_dhparam(new_resource.key_length, new_resource.generator).to_pem

      log "Generating #{new_resource.key_length} bit "\
          "dhparam file at #{new_resource.path}, this may take some time"

      file new_resource.path do
        action :create
        owner new_resource.owner
        group new_resource.group
        mode new_resource.mode
        sensitive true
        content dhparam_content
      end
    end
  end
end
