# Author:: Joshua Timberman <joshua@chef.io>
# Copyright:: 2009-2017, Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default['postfix']['packages'] = %w(postfix)

# Generic cookbook attributes
default['postfix']['mail_type'] = 'client'
default['postfix']['relayhost_role'] = 'relayhost'
default['postfix']['relayhost_port'] = '25'
default['postfix']['multi_environment_relay'] = false
default['postfix']['use_procmail'] = false
default['postfix']['use_alias_maps'] = (node['platform'] == 'freebsd')
default['postfix']['use_transport_maps'] = false
default['postfix']['use_access_maps'] = false
default['postfix']['use_virtual_aliases'] = false
default['postfix']['use_virtual_aliases_domains'] = false
default['postfix']['use_relay_restrictions_maps'] = false
default['postfix']['transports'] = {}
default['postfix']['access'] = {}
default['postfix']['virtual_aliases'] = {}
default['postfix']['virtual_aliases_domains'] = {}
default['postfix']['main_template_source'] = 'postfix'
default['postfix']['master_template_source'] = 'postfix'
default['postfix']['sender_canonical_map_entries'] = {}
default['postfix']['smtp_generic_map_entries'] = {}
default['postfix']['recipient_canonical_map_entries'] = {}
default['postfix']['access_db_type'] = 'hash'
default['postfix']['aliases_db_type'] = 'hash'
default['postfix']['transport_db_type'] = 'hash'
default['postfix']['virtual_alias_db_type'] = 'hash'
default['postfix']['virtual_alias_domains_db_type'] = 'hash'

case node['platform']
when 'smartos'
  default['postfix']['conf_dir'] = '/opt/local/etc/postfix'
  default['postfix']['aliases_db'] = '/opt/local/etc/postfix/aliases'
  default['postfix']['transport_db'] = '/opt/local/etc/postfix/transport'
  default['postfix']['access_db'] = '/opt/local/etc/postfix/access'
  default['postfix']['virtual_alias_db'] = '/opt/local/etc/postfix/virtual'
  default['postfix']['virtual_alias_domains_db'] = '/opt/local/etc/postfix/virtual_domains'
  default['postfix']['relay_restrictions_db'] = '/opt/local/etc/postfix/relay_restrictions'
when 'freebsd'
  default['postfix']['conf_dir'] = '/usr/local/etc/postfix'
  default['postfix']['aliases_db'] = '/etc/aliases'
  default['postfix']['transport_db'] = '/usr/local/etc/postfix/transport'
  default['postfix']['access_db'] = '/usr/local/etc/postfix/access'
  default['postfix']['virtual_alias_db'] = '/usr/local/etc/postfix/virtual'
  default['postfix']['virtual_alias_domains_db'] = '/usr/local/etc/postfix/virtual_domains'
  default['postfix']['relay_restrictions_db'] = '/etc/postfix/relay_restrictions'
when 'omnios'
  default['postfix']['conf_dir'] = '/opt/omni/etc/postfix'
  default['postfix']['aliases_db'] = '/opt/omni/etc/postfix/aliases'
  default['postfix']['transport_db'] = '/opt/omni/etc/postfix/transport'
  default['postfix']['access_db'] = '/opt/omni/etc/postfix/access'
  default['postfix']['virtual_alias_db'] = '/etc/omni/etc/postfix/virtual'
  default['postfix']['virtual_alias_domains_db'] = '/etc/omni/etc/postfix/virtual_domains'
  default['postfix']['relay_restrictions_db'] = '/opt/omni/etc/postfix/relay_restrictions'
  default['postfix']['uid'] = 11
else
  default['postfix']['conf_dir'] = '/etc/postfix'
  default['postfix']['aliases_db'] = '/etc/aliases'
  default['postfix']['transport_db'] = '/etc/postfix/transport'
  default['postfix']['access_db'] = '/etc/postfix/access'
  default['postfix']['virtual_alias_db'] = '/etc/postfix/virtual'
  default['postfix']['virtual_alias_domains_db'] = '/etc/postfix/virtual_domains'
  default['postfix']['relay_restrictions_db'] = '/etc/postfix/relay_restrictions'
end

# Non-default main.cf attributes
default['postfix']['main']['biff'] = 'no'
default['postfix']['main']['append_dot_mydomain'] = 'no'
default['postfix']['main']['myhostname'] = (node['fqdn'] || node['hostname']).to_s.chomp('.')
default['postfix']['main']['mydomain'] = (node['domain'] || node['hostname']).to_s.chomp('.')
default['postfix']['main']['myorigin'] = '$myhostname'
default['postfix']['main']['mydestination'] = [node['postfix']['main']['myhostname'], node['hostname'], 'localhost.localdomain', 'localhost'].compact
default['postfix']['main']['smtpd_use_tls'] = 'yes'
default['postfix']['main']['smtp_use_tls'] = 'yes'
default['postfix']['main']['smtp_sasl_auth_enable'] = 'no'
default['postfix']['main']['mailbox_size_limit'] = 0
default['postfix']['main']['mynetworks'] = nil
default['postfix']['main']['inet_interfaces'] = 'loopback-only'

# Conditional attributes, also reference _attributes recipe
case node['platform_family']
when 'debian'
  default['postfix']['cafile'] = '/etc/ssl/certs/ca-certificates.crt'
when 'smartos'
  default['postfix']['main']['smtpd_use_tls'] = 'no'
  default['postfix']['main']['smtp_use_tls'] = 'no'
  default['postfix']['cafile'] = '/opt/local/etc/postfix/cacert.pem'
when 'rhel'
  default['postfix']['cafile'] = '/etc/pki/tls/cert.pem'
when 'amazon'
  default['postfix']['cafile'] = '/etc/pki/tls/cert.pem'
else
  default['postfix']['cafile'] = "#{node['postfix']['conf_dir']}/cacert.pem"
end

# # Default main.cf attributes according to `postconf -d`
# default['postfix']['main']['relayhost'] = ''
# default['postfix']['main']['milter_default_action']  = 'tempfail'
# default['postfix']['main']['milter_protocol']  = '6'
# default['postfix']['main']['smtpd_milters']  = ''
# default['postfix']['main']['non_smtpd_milters']  = ''
# default['postfix']['main']['sender_canonical_classes'] = nil
# default['postfix']['main']['recipient_canonical_classes'] = nil
# default['postfix']['main']['canonical_classes'] = nil
# default['postfix']['main']['sender_canonical_maps'] = nil
# default['postfix']['main']['recipient_canonical_maps'] = nil
# default['postfix']['main']['canonical_maps'] = nil

# Master.cf attributes
default['postfix']['master']['smtp']['active'] = true
default['postfix']['master']['smtp']['order'] = 10
default['postfix']['master']['smtp']['type'] = 'inet'
default['postfix']['master']['smtp']['private'] = false
default['postfix']['master']['smtp']['chroot'] = false
default['postfix']['master']['smtp']['command'] = 'smtpd'
default['postfix']['master']['smtp']['args'] = []

default['postfix']['master']['submission']['active'] = false
default['postfix']['master']['submission']['order'] = 20
default['postfix']['master']['submission']['type'] = 'inet'
default['postfix']['master']['submission']['private'] = false
default['postfix']['master']['submission']['chroot'] = false
default['postfix']['master']['submission']['command'] = 'smtpd'
default['postfix']['master']['submission']['args'] = ['-o smtpd_enforce_tls=yes', ' -o smtpd_sasl_auth_enable=yes', '-o smtpd_client_restrictions=permit_sasl_authenticated,reject']

default['postfix']['master']['smtps']['active'] = false
default['postfix']['master']['smtps']['order'] = 30
default['postfix']['master']['smtps']['type'] = 'inet'
default['postfix']['master']['smtps']['private'] = false
default['postfix']['master']['smtps']['chroot'] = false
default['postfix']['master']['smtps']['command'] = 'smtpd'
default['postfix']['master']['smtps']['args'] = ['-o smtpd_tls_wrappermode=yes', '-o smtpd_sasl_auth_enable=yes', '-o smtpd_client_restrictions=permit_sasl_authenticated,reject']

default['postfix']['master']['628']['active'] = false
default['postfix']['master']['628']['order'] = 40
default['postfix']['master']['628']['type'] = 'inet'
default['postfix']['master']['628']['private'] = false
default['postfix']['master']['628']['chroot'] = false
default['postfix']['master']['628']['command'] = 'qmqpdd'
default['postfix']['master']['628']['args'] = []

default['postfix']['master']['pickup']['active'] = true
default['postfix']['master']['pickup']['order'] = 50
default['postfix']['master']['pickup']['type'] = 'fifo'
default['postfix']['master']['pickup']['private'] = false
default['postfix']['master']['pickup']['chroot'] = false
default['postfix']['master']['pickup']['wakeup'] = '60'
default['postfix']['master']['pickup']['maxproc'] = '1'
default['postfix']['master']['pickup']['command'] = 'pickup'
default['postfix']['master']['pickup']['args'] = []

default['postfix']['master']['cleanup']['active'] = true
default['postfix']['master']['cleanup']['order'] = 60
default['postfix']['master']['cleanup']['type'] = 'unix'
default['postfix']['master']['cleanup']['private'] = false
default['postfix']['master']['cleanup']['chroot'] = false
default['postfix']['master']['cleanup']['maxproc'] = '0'
default['postfix']['master']['cleanup']['command'] = 'cleanup'
default['postfix']['master']['cleanup']['args'] = []

default['postfix']['master']['qmgr']['active'] = true
default['postfix']['master']['qmgr']['order'] = 70
default['postfix']['master']['qmgr']['type'] = 'fifo'
default['postfix']['master']['qmgr']['private'] = false
default['postfix']['master']['qmgr']['chroot'] = false
default['postfix']['master']['qmgr']['wakeup'] = '300'
default['postfix']['master']['qmgr']['maxproc'] = '1'
default['postfix']['master']['qmgr']['command'] = 'qmgr'
default['postfix']['master']['qmgr']['args'] = []

default['postfix']['master']['tlsmgr']['active'] = true
default['postfix']['master']['tlsmgr']['order'] = 80
default['postfix']['master']['tlsmgr']['type'] = 'unix'
default['postfix']['master']['tlsmgr']['chroot'] = false
default['postfix']['master']['tlsmgr']['wakeup'] = '1000?'
default['postfix']['master']['tlsmgr']['maxproc'] = '1'
default['postfix']['master']['tlsmgr']['command'] = 'tlsmgr'
default['postfix']['master']['tlsmgr']['args'] = []

default['postfix']['master']['rewrite']['active'] = true
default['postfix']['master']['rewrite']['order'] = 90
default['postfix']['master']['rewrite']['type'] = 'unix'
default['postfix']['master']['rewrite']['chroot'] = false
default['postfix']['master']['rewrite']['command'] = 'trivial-rewrite'
default['postfix']['master']['rewrite']['args'] = []

default['postfix']['master']['bounce']['active'] = true
default['postfix']['master']['bounce']['order'] = 100
default['postfix']['master']['bounce']['type'] = 'unix'
default['postfix']['master']['bounce']['chroot'] = false
default['postfix']['master']['bounce']['maxproc'] = '0'
default['postfix']['master']['bounce']['command'] = 'bounce'
default['postfix']['master']['bounce']['args'] = []

default['postfix']['master']['defer']['active'] = true
default['postfix']['master']['defer']['order'] = 110
default['postfix']['master']['defer']['type'] = 'unix'
default['postfix']['master']['defer']['chroot'] = false
default['postfix']['master']['defer']['maxproc'] = '0'
default['postfix']['master']['defer']['command'] = 'bounce'
default['postfix']['master']['defer']['args'] = []

default['postfix']['master']['trace']['active'] = true
default['postfix']['master']['trace']['order'] = 120
default['postfix']['master']['trace']['type'] = 'unix'
default['postfix']['master']['trace']['chroot'] = false
default['postfix']['master']['trace']['maxproc'] = '0'
default['postfix']['master']['trace']['command'] = 'bounce'
default['postfix']['master']['trace']['args'] = []

default['postfix']['master']['verify']['active'] = true
default['postfix']['master']['verify']['order'] = 130
default['postfix']['master']['verify']['type'] = 'unix'
default['postfix']['master']['verify']['chroot'] = false
default['postfix']['master']['verify']['maxproc'] = '1'
default['postfix']['master']['verify']['command'] = 'verify'
default['postfix']['master']['verify']['args'] = []

default['postfix']['master']['flush']['active'] = true
default['postfix']['master']['flush']['order'] = 140
default['postfix']['master']['flush']['type'] = 'unix'
default['postfix']['master']['flush']['private'] = false
default['postfix']['master']['flush']['chroot'] = false
default['postfix']['master']['flush']['wakeup'] = '1000?'
default['postfix']['master']['flush']['maxproc'] = '0'
default['postfix']['master']['flush']['command'] = 'flush'
default['postfix']['master']['flush']['args'] = []

default['postfix']['master']['proxymap']['active'] = true
default['postfix']['master']['proxymap']['order'] = 150
default['postfix']['master']['proxymap']['type'] = 'unix'
default['postfix']['master']['proxymap']['chroot'] = false
default['postfix']['master']['proxymap']['command'] = 'proxymap'
default['postfix']['master']['proxymap']['args'] = []

default['postfix']['master']['smtpunix']['service'] = 'smtp'
default['postfix']['master']['smtpunix']['active'] = true
default['postfix']['master']['smtpunix']['order'] = 160
default['postfix']['master']['smtpunix']['type'] = 'unix'
default['postfix']['master']['smtpunix']['chroot'] = false
default['postfix']['master']['smtpunix']['maxproc'] = '500'
default['postfix']['master']['smtpunix']['command'] = 'smtp'
default['postfix']['master']['smtpunix']['args'] = []

default['postfix']['master']['relay']['active'] = true
default['postfix']['master']['relay']['comment'] = 'When relaying mail as backup MX, disable fallback_relay to avoid MX loops'
default['postfix']['master']['relay']['order'] = 170
default['postfix']['master']['relay']['type'] = 'unix'
default['postfix']['master']['relay']['chroot'] = false
default['postfix']['master']['relay']['command'] = 'smtp'
default['postfix']['master']['relay']['args'] = ['-o smtp_fallback_relay=']

default['postfix']['master']['showq']['active'] = true
default['postfix']['master']['showq']['order'] = 180
default['postfix']['master']['showq']['type'] = 'unix'
default['postfix']['master']['showq']['private'] = false
default['postfix']['master']['showq']['chroot'] = false
default['postfix']['master']['showq']['command'] = 'showq'
default['postfix']['master']['showq']['args'] = []

default['postfix']['master']['error']['active'] = true
default['postfix']['master']['error']['order'] = 190
default['postfix']['master']['error']['type'] = 'unix'
default['postfix']['master']['error']['chroot'] = false
default['postfix']['master']['error']['command'] = 'error'
default['postfix']['master']['error']['args'] = []

default['postfix']['master']['discard']['active'] = true
default['postfix']['master']['discard']['order'] = 200
default['postfix']['master']['discard']['type'] = 'unix'
default['postfix']['master']['discard']['chroot'] = false
default['postfix']['master']['discard']['command'] = 'discard'
default['postfix']['master']['discard']['args'] = []

default['postfix']['master']['local']['active'] = true
default['postfix']['master']['local']['order'] = 210
default['postfix']['master']['local']['type'] = 'unix'
default['postfix']['master']['local']['unpriv'] = false
default['postfix']['master']['local']['chroot'] = false
default['postfix']['master']['local']['command'] = 'local'
default['postfix']['master']['local']['args'] = []

default['postfix']['master']['virtual']['active'] = true
default['postfix']['master']['virtual']['order'] = 220
default['postfix']['master']['virtual']['type'] = 'unix'
default['postfix']['master']['virtual']['unpriv'] = false
default['postfix']['master']['virtual']['chroot'] = false
default['postfix']['master']['virtual']['command'] = 'virtual'
default['postfix']['master']['virtual']['args'] = []

default['postfix']['master']['lmtp']['active'] = true
default['postfix']['master']['lmtp']['order'] = 230
default['postfix']['master']['lmtp']['type'] = 'unix'
default['postfix']['master']['lmtp']['chroot'] = false
default['postfix']['master']['lmtp']['command'] = 'lmtp'
default['postfix']['master']['lmtp']['args'] = []

default['postfix']['master']['anvil']['active'] = true
default['postfix']['master']['anvil']['order'] = 240
default['postfix']['master']['anvil']['type'] = 'unix'
default['postfix']['master']['anvil']['chroot'] = false
default['postfix']['master']['anvil']['maxproc'] = '1'
default['postfix']['master']['anvil']['command'] = 'anvil'
default['postfix']['master']['anvil']['args'] = []

default['postfix']['master']['scache']['active'] = true
default['postfix']['master']['scache']['order'] = 250
default['postfix']['master']['scache']['type'] = 'unix'
default['postfix']['master']['scache']['chroot'] = false
default['postfix']['master']['scache']['maxproc'] = '1'
default['postfix']['master']['scache']['command'] = 'scache'
default['postfix']['master']['scache']['args'] = []

default['postfix']['master']['maildrop']['active'] = true
default['postfix']['master']['maildrop']['comment'] = 'See the Postfix MAILDROP_README file for details. To main.cf will be added: maildrop_destination_recipient_limit=1'
default['postfix']['master']['maildrop']['order'] = 510
default['postfix']['master']['maildrop']['type'] = 'unix'
default['postfix']['master']['maildrop']['unpriv'] = false
default['postfix']['master']['maildrop']['chroot'] = false
default['postfix']['master']['maildrop']['command'] = 'pipe'
default['postfix']['master']['maildrop']['args'] = ['flags=DRhu user=vmail argv=/usr/local/bin/maildrop -d ${recipient}']

default['postfix']['master']['old-cyrus']['active'] = false
default['postfix']['master']['old-cyrus']['comment'] = 'The Cyrus deliver program has changed incompatibly, multiple times.'
default['postfix']['master']['old-cyrus']['order'] = 520
default['postfix']['master']['old-cyrus']['type'] = 'unix'
default['postfix']['master']['old-cyrus']['unpriv'] = false
default['postfix']['master']['old-cyrus']['chroot'] = false
default['postfix']['master']['old-cyrus']['command'] = 'pipe'
default['postfix']['master']['old-cyrus']['args'] = ['flags=R user=cyrus argv=/usr/lib/cyrus-imapd/deliver -e -m ${extension} ${user}']

default['postfix']['master']['cyrus']['active'] = true
default['postfix']['master']['cyrus']['comment'] = 'Cyrus 2.1.5 (Amos Gouaux). To main.cf will be added: cyrus_destination_recipient_limit=1'
default['postfix']['master']['cyrus']['order'] = 530
default['postfix']['master']['cyrus']['type'] = 'unix'
default['postfix']['master']['cyrus']['unpriv'] = false
default['postfix']['master']['cyrus']['chroot'] = false
default['postfix']['master']['cyrus']['command'] = 'pipe'
default['postfix']['master']['cyrus']['args'] = ['user=cyrus argv=/usr/lib/cyrus-imapd/deliver -e -r ${sender} -m ${extension} ${user}']

default['postfix']['master']['uucp']['active'] = true
default['postfix']['master']['uucp']['comment'] = 'See the Postfix UUCP_README file for configuration details.'
default['postfix']['master']['uucp']['order'] = 540
default['postfix']['master']['uucp']['type'] = 'unix'
default['postfix']['master']['uucp']['unpriv'] = false
default['postfix']['master']['uucp']['chroot'] = false
default['postfix']['master']['uucp']['command'] = 'pipe'
default['postfix']['master']['uucp']['args'] = ['flags=Fqhu user=uucp argv=uux -r -n -z -a$sender - $nexthop!rmail ($recipient)']

default['postfix']['master']['ifmail']['active'] = false
default['postfix']['master']['ifmail']['order'] = 550
default['postfix']['master']['ifmail']['type'] = 'unix'
default['postfix']['master']['ifmail']['unpriv'] = false
default['postfix']['master']['ifmail']['chroot'] = false
default['postfix']['master']['ifmail']['command'] = 'pipe'
default['postfix']['master']['ifmail']['args'] = ['flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r $nexthop ($recipient)']

default['postfix']['master']['bsmtp']['active'] = true
default['postfix']['master']['bsmtp']['order'] = 560
default['postfix']['master']['bsmtp']['type'] = 'unix'
default['postfix']['master']['bsmtp']['unpriv'] = false
default['postfix']['master']['bsmtp']['chroot'] = false
default['postfix']['master']['bsmtp']['command'] = 'pipe'
default['postfix']['master']['bsmtp']['args'] = ['flags=Fq. user=foo argv=/usr/local/sbin/bsmtp -f $sender $nexthop $recipient']

# OS Aliases
default['postfix']['aliases'] = case node['platform']
                                when 'freebsd'
                                  {
                                    'MAILER-DAEMON' =>  'postmaster',
                                    'bin' =>            'root',
                                    'daemon' =>         'root',
                                    'named' =>          'root',
                                    'nobody' =>         'root',
                                    'uucp' =>           'root',
                                    'www' =>            'root',
                                    'ftp-bugs' =>       'root',
                                    'postfix' =>        'root',
                                    'manager' =>        'root',
                                    'dumper' =>         'root',
                                    'operator' =>       'root',
                                    'abuse' =>          'postmaster',
                                  }
                                else
                                  {}
                                end

if node['postfix']['use_relay_restrictions_maps']
  default['postfix']['main']['smtpd_relay_restrictions'] = "hash:#{node['postfix']['relay_restrictions_db']}, reject"
end
