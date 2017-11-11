include OpenSSLCookbook::Helpers

property :name,        String, name_property: true
property :key_length,  equal_to: [1024, 2048, 4096, 8192], default: 2048
property :key_pass,    String
property :owner,       String
property :group,       String
property :mode,        [Integer, String]

action :create do
  unless key_file_valid?(new_resource.name, new_resource.key_pass)
    converge_by("Create an RSA key #{@new_resource}") do
      log "Generating #{new_resource.key_length} bit "\
          "RSA key file at #{new_resource.name}, this may take some time"

      if new_resource.key_pass
        unencrypted_rsa_key = gen_rsa_key(new_resource.key_length)
        rsa_key_content = encrypt_rsa_key(unencrypted_rsa_key, new_resource.key_pass)
      else
        rsa_key_content = gen_rsa_key(new_resource.key_length).to_pem
      end

      file new_resource.name do
        action :create
        owner new_resource.owner
        group new_resource.group
        mode new_resource.mode
        sensitive true
        content rsa_key_content
      end
    end
  end
end
