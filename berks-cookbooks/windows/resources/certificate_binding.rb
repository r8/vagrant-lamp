#
# Author:: Richard Lavey (richard.lavey@calastone.com)
# Cookbook:: windows
# Resource:: certificate_binding
#
# Copyright:: 2015-2017, Calastone Ltd.
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

include Chef::Mixin::ShellOut
include Chef::Mixin::PowershellOut
include Windows::Helper

property :cert_name, String, name_property: true, required: true
property :name_kind, Symbol, equal_to: [:hash, :subject], default: :subject
property :address, String, default: '0.0.0.0'
property :port, Integer, default: 443
property :app_id, String, default: '{4dc3e181-e14b-4a21-b022-59fc669b0914}'
property :store_name, String, default: 'MY', equal_to: ['TRUSTEDPUBLISHER', 'CLIENTAUTHISSUER', 'REMOTE DESKTOP', 'ROOT', 'TRUSTEDDEVICES', 'WEBHOSTING', 'CA', 'AUTHROOT', 'TRUSTEDPEOPLE', 'MY', 'SMARTCARDROOT', 'TRUST']
property :exists, [true, false], desired_state: true

load_current_value do |desired|
  cmd = shell_out("#{locate_sysnative_cmd('netsh.exe')} http show sslcert ipport=#{desired.address}:#{desired.port}")
  Chef::Log.debug "netsh reports: #{cmd.stdout}"

  address desired.address
  port desired.port
  store_name desired.store_name
  app_id desired.app_id

  if cmd.exitstatus == 0
    m = cmd.stdout.scan(/Certificate Hash\s+:\s?([A-Fa-f0-9]{40})/)
    raise "Failed to extract hash from command output #{cmd.stdout}" if m.empty?
    cert_name m[0][0]
    name_kind :hash
    exists true
  else
    exists false
  end
end

action :create do
  hash = new_resource.name_kind == :subject ? hash_from_subject : new_resource.cert_name

  if current_resource.exists
    needs_change = (hash.casecmp(current_resource.cert_name) != 0)

    if needs_change
      converge_by("Changing #{current_resource.address}:#{current_resource.port}") do
        delete_binding
        add_binding hash
      end
    else
      Chef::Log.debug("#{new_resource.address}:#{new_resource.port} already bound to #{hash} - nothing to do")
    end
  else
    converge_by("Binding #{new_resource.address}:#{new_resource.port}") do
      add_binding hash
    end
  end
end

action :delete do
  if current_resource.exists
    converge_by("Deleting #{current_resource.address}:#{current_resource.port}") do
      delete_binding
    end
  else
    Chef::Log.debug("#{current_resource.address}:#{current_resource.port} not bound - nothing to do")
  end
end

action_class do
  def netsh_command
    locate_sysnative_cmd('netsh.exe')
  end

  def add_binding(hash)
    cmd = "#{netsh_command} http add sslcert"
    cmd << " ipport=#{current_resource.address}:#{current_resource.port}"
    cmd << " certhash=#{hash}"
    cmd << " appid=#{current_resource.app_id}"
    cmd << " certstorename=#{current_resource.store_name}"
    check_hash hash

    shell_out!(cmd)
  end

  def delete_binding
    shell_out!("#{netsh_command} http delete sslcert ipport=#{current_resource.address}:#{current_resource.port}")
  end

  def check_hash(hash)
    p = powershell_out!("Test-Path \"cert:\\LocalMachine\\#{current_resource.store_name}\\#{hash}\"")

    unless p.stderr.empty? && p.stdout =~ /True/i
      raise "A Cert with hash of #{hash} doesn't exist in keystore LocalMachine\\#{current_resource.store_name}"
    end
    nil
  end

  def hash_from_subject
    # escape wildcard subject name (*.acme.com)
    subject = new_resource.cert_name.sub(/\*/, '`*')
    ps_script = "& { gci cert:\\localmachine\\#{new_resource.store_name} | where { $_.subject -like '*#{subject}*' } | select -first 1 -expandproperty Thumbprint }"

    Chef::Log.debug "Running PS script #{ps_script}"
    p = powershell_out!(ps_script)

    raise "#{ps_script} failed with #{p.stderr}" if !p.stderr.nil? && !p.stderr.empty?
    raise "Couldn't find thumbprint for subject #{new_resource.cert_name}" if p.stdout.nil? || p.stdout.empty?

    # seem to get a UTF-8 string with BOM returned sometimes! Strip any such BOM
    hash = p.stdout.strip
    hash[0].ord == 239 ? hash.force_encoding('UTF-8').delete!("\xEF\xBB\xBF".force_encoding('UTF-8')) : hash
  end
end
