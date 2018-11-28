#
# Copyright:: Copyright 2018, Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

chef_version_for_provides '< 14.4' if respond_to?(:chef_version_for_provides)
resource_name :openssl_ec_private_key

include OpenSSLCookbook::Helpers

property :path,        String, name_property: true
property :key_curve,   equal_to: %w(secp384r1 secp521r1 prime256v1 secp224r1 secp256k1), default: 'prime256v1'
property :key_pass,    String
property :key_cipher,  String, default: 'des3', equal_to: ::OpenSSL::Cipher.ciphers
property :owner,       String
property :group,       String
property :mode,        [Integer, String], default: '0640'
property :force,       [true, false], default: false

action :create do
  unless new_resource.force || priv_key_file_valid?(new_resource.path, new_resource.key_pass)
    converge_by("Create an EC private key #{new_resource.path}") do
      log "Generating an #{new_resource.key_curve} "\
          "EC key file at #{new_resource.name}, this may take some time"

      if new_resource.key_pass
        unencrypted_ec_key = gen_ec_priv_key(new_resource.key_curve)
        ec_key_content = encrypt_ec_key(unencrypted_ec_key, new_resource.key_pass, new_resource.key_cipher)
      else
        ec_key_content = gen_ec_priv_key(new_resource.key_curve).to_pem
      end

      file new_resource.path do
        action :create
        owner new_resource.owner unless new_resource.owner.nil?
        group new_resource.group unless new_resource.group.nil?
        mode new_resource.mode
        sensitive true
        content ec_key_content
      end
    end
  end
end
