include OpenSSLCookbook::Helpers

property :name,        String, name_property: true
property :key_length,  equal_to: [1024, 2048, 4096, 8192], default: 2048
property :generator,   equal_to: [2, 5], default: 2
property :owner,       String
property :group,       String
property :mode,        [Integer, String]

action :create do
  unless dhparam_pem_valid?(new_resource.name) # ~FC023
    converge_by("Create a dhparam file #{@new_resource}") do
      dhparam_content = gen_dhparam(new_resource.key_length, new_resource.generator).to_pem

      log "Generating #{new_resource.key_length} bit "\
          "dhparam file at #{new_resource.name}, this may take some time"

      file new_resource.name do
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
