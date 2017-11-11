#
# Cookbook Name:: mailhog
# Recipe:: default
#
# Copyright (c) 2015 Sergey Storchay, All Rights Reserved.
# Modified 2016 Gleb Levitin, dkd Internet Service GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

include_recipe 'runit::default'

arch = node['kernel']['machine'] =~ /x86_64/ ? 'amd64' : '386'

if node['mailhog']['binary']['url']
  binary_url = node['mailhog']['binary']['url']
  checksum = node['mailhog']['binary']['checksum']
else
  binary_url = "#{node['mailhog']['binary']['prefix_url']}#{node['mailhog']['version']}/MailHog_linux_#{arch}"
  checksum = node['mailhog']['binary']['checksum']["linux_#{arch}"]
end

# Download and install binary file
remote_file node['mailhog']['binary']['path'] do
  source binary_url
  checksum checksum
  mode node['mailhog']['binary']['mode']
  action :create
end

# Setup runit service
runit_service 'mailhog' do
  options({
    :smtp_ip => node['mailhog']['smtp']['ip'],
    :smtp_port => node['mailhog']['smtp']['port'],
    :smtp_outgoing => node['mailhog']['smtp']['outgoing'],
    :ui_ip => node['mailhog']['ui']['ip'],
    :ui_port => node['mailhog']['ui']['port'],
    :api_ip => node['mailhog']['api']['ip'],
    :api_port => node['mailhog']['api']['port'],
    :cors_origin => node['mailhog']['cors-origin'],
    :hostname => node['mailhog']['hostname'],
    :storage => node['mailhog']['storage'],
    :mongodb_ip => node['mailhog']['mongodb']['ip'],
    :mongodb_port => node['mailhog']['mongodb']['port'],
    :mongodb_db => node['mailhog']['mongodb']['db'],
    :mongodb_collection => node['mailhog']['mongodb']['collection'],
    :jim_enable => node['mailhog']['jim']['enable'],
    :jim_accept => node['mailhog']['jim']['accept'],
    :jim_disconnect => node['mailhog']['jim']['disconnect'],
    :jim_linkspeed_affect => node['mailhog']['jim']['linkspeed']['affect'],
    :jim_linkspeed_max => node['mailhog']['jim']['linkspeed']['max'],
    :jim_linkspeed_min => node['mailhog']['jim']['linkspeed']['min'],
    :jim_reject_auth => node['mailhog']['jim']['reject']['auth'],
    :jim_reject_recipient => node['mailhog']['jim']['reject']['recipient'],
    :jim_reject_sender => node['mailhog']['jim']['reject']['sender']
  })
  default_logger true
  owner node['mailhog']['service']['owner']
  group node['mailhog']['service']['group']
  action [:enable, :restart]
end
