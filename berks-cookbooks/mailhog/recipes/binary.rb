#
# Cookbook Name:: mailhog
# Recipe:: default
#
# Copyright (c) 2015 Sergey Storchay, All Rights Reserved.
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

include_recipe 'runit'

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
  default_logger true
end
