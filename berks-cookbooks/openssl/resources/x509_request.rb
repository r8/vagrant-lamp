#
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
resource_name :openssl_x509_request

include OpenSSLCookbook::Helpers

property :path,             String, name_property: true
property :owner,            String
property :group,            String
property :mode,             [Integer, String], default: '0644'
property :country,          String
property :state,            String
property :city,             String
property :org,              String
property :org_unit,         String
property :common_name,      String, required: true
property :email,            String
property :key_file,         String
property :key_pass,         String
property :key_type,         equal_to: %w(rsa ec), default: 'ec'
property :key_length,       equal_to: [1024, 2048, 4096, 8192], default: 2048
property :key_curve,        equal_to: %w(secp384r1 secp521r1 prime256v1), default: 'prime256v1'

action :create do
  unless ::File.exist? new_resource.path
    converge_by("Create CSR #{@new_resource}") do
      file new_resource.name do
        owner new_resource.owner unless new_resource.owner.nil?
        group new_resource.group unless new_resource.group.nil?
        mode new_resource.mode
        content csr.to_pem
        action :create
      end

      file new_resource.key_file do
        mode new_resource.mode
        owner new_resource.owner unless new_resource.owner.nil?
        group new_resource.group unless new_resource.group.nil?
        content key.to_pem
        sensitive true
        action :create_if_missing
      end
    end
  end
end

action_class do
  def generate_key_file
    unless new_resource.key_file
      path, file = ::File.split(new_resource.path)
      filename = ::File.basename(file, ::File.extname(file))
      new_resource.key_file path + '/' + filename + '.key'
    end
    new_resource.key_file
  end

  def key
    @key ||= if priv_key_file_valid?(generate_key_file, new_resource.key_pass)
               ::OpenSSL::PKey.read ::File.read(generate_key_file), new_resource.key_pass
             elsif new_resource.key_type == 'rsa'
               gen_rsa_priv_key(new_resource.key_length)
             else
               gen_ec_priv_key(new_resource.key_curve)
             end
    @key
  end

  def subject
    csr_subject = ::OpenSSL::X509::Name.new()
    csr_subject.add_entry('C', new_resource.country) unless new_resource.country.nil?
    csr_subject.add_entry('ST', new_resource.state) unless new_resource.state.nil?
    csr_subject.add_entry('L', new_resource.city) unless new_resource.city.nil?
    csr_subject.add_entry('O', new_resource.org) unless new_resource.org.nil?
    csr_subject.add_entry('OU', new_resource.org_unit) unless new_resource.org_unit.nil?
    csr_subject.add_entry('CN', new_resource.common_name)
    csr_subject.add_entry('emailAddress', new_resource.email) unless new_resource.email.nil?
    csr_subject
  end

  def csr
    gen_x509_request(subject, key)
  end
end
