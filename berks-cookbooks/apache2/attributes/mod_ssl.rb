#
# Cookbook:: apache2
# Attributes:: mod_ssl
#
# Copyright:: 2012-2013, Chef Software, Inc.
# Copyright:: 2014, Viverae, Inc.
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

default['apache']['mod_ssl']['port'] = 443
default['apache']['mod_ssl']['protocol'] = 'All -SSLv2 -SSLv3'
default['apache']['mod_ssl']['cipher_suite'] = 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA256:EECDH:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA128-SHA:AES128-SHA'
default['apache']['mod_ssl']['honor_cipher_order']     = 'On'
default['apache']['mod_ssl']['insecure_renegotiation'] = 'Off'
default['apache']['mod_ssl']['strict_sni_vhost_check'] = 'Off'
default['apache']['mod_ssl']['session_cache'] = 'shmcb:/var/run/apache2/ssl_scache'
default['apache']['mod_ssl']['session_cache_timeout'] = 300
default['apache']['mod_ssl']['compression'] = 'Off'
default['apache']['mod_ssl']['use_stapling'] = 'Off'
default['apache']['mod_ssl']['stapling_responder_timeout'] = 5
default['apache']['mod_ssl']['stapling_return_responder_errors'] = 'Off'
default['apache']['mod_ssl']['stapling_cache'] = 'shmcb:/var/run/ocsp(128000)'
default['apache']['mod_ssl']['pass_phrase_dialog'] = 'builtin'
default['apache']['mod_ssl']['mutex'] = 'file:/var/run/apache2/ssl_mutex'
default['apache']['mod_ssl']['directives'] = {}
default['apache']['mod_ssl']['pkg_name'] = 'mod_ssl'

case node['platform_family']
when 'debian'
  if platform?('ubuntu')
    default['apache']['mod_ssl']['pass_phrase_dialog'] = 'exec:/usr/share/apache2/ask-for-passphrase'
  end
when 'freebsd'
  default['apache']['mod_ssl']['session_cache'] = 'shmcb:/var/run/ssl_scache(512000)'
  default['apache']['mod_ssl']['mutex'] = 'file:/var/run/ssl_mutex'
when 'rhel', 'fedora', 'suse', 'amazon'
  default['apache']['mod_ssl']['pkg_name'] = 'mod24_ssl' if platform?('amazon') && node['platform_version'] == 1
  default['apache']['mod_ssl']['session_cache'] = 'shmcb:/var/cache/mod_ssl/scache(512000)'
  default['apache']['mod_ssl']['mutex'] = 'default'
end
