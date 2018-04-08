provides :openssl_rsa_key # legacy name
provides :openssl_rsa_private_key

include OpenSSLCookbook::Helpers

property :path,        String, name_property: true
property :key_length,  equal_to: [1024, 2048, 4096, 8192], default: 2048
property :key_pass,    String
property :key_cipher,  String, default: 'des3', equal_to: OpenSSL::Cipher.ciphers
property :owner,       String, default: node['platform'] == 'windows' ? 'Administrator' : 'root'
property :group,       String, default: node['root_group']
property :mode,        [Integer, String], default: '0640'
property :force,       [true, false], default: false

action :create do
  unless new_resource.force || priv_key_file_valid?(new_resource.path, new_resource.key_pass)
    converge_by("Create an RSA private key #{new_resource.path}") do
      log "Generating #{new_resource.key_length} bit "\
          "RSA key file at #{new_resource.path}, this may take some time"

      if new_resource.key_pass
        unencrypted_rsa_key = gen_rsa_priv_key(new_resource.key_length)
        rsa_key_content = encrypt_rsa_key(unencrypted_rsa_key, new_resource.key_pass, new_resource.key_cipher)
      else
        rsa_key_content = gen_rsa_priv_key(new_resource.key_length).to_pem
      end

      file new_resource.path do
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
