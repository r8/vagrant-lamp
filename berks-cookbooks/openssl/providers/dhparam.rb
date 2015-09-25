#
# dhparam.pem provider
#
# Author:: Charles Johnson <charles@chef.io>
#

include OpenSSLCookbook::Helpers

use_inline_resources

def whyrun_supported?
  true
end

action :create do
  converge_by("Create a dhparam file #{@new_resource}") do
    unless dhparam_pem_valid?(new_resource.name)
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
