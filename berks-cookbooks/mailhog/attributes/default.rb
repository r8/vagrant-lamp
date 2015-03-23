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

default['mailhog']['version'] = '0.1.6'
default['mailhog']['install_method'] = 'binary'

default['mailhog']['binary']['url'] = nil # Set it to override automatical generation

default['mailhog']['binary']['mode'] = 0755
default['mailhog']['binary']['path'] = '/usr/local/bin/MailHog'

default['mailhog']['binary']['prefix_url'] = 'http://github.com/mailhog/MailHog/releases/download/v'
default['mailhog']['binary']['checksum']['linux_386'] = 'a72d1016b70964562c8a77a3b57637a77889ee61f3b22973e0a7beb17181d8da'
default['mailhog']['binary']['checksum']['linux_amd64'] = 'e8e9acb4fa4470f4d4c3a4bba312f335bfc28122ea723599531699f099b4c9a5'
