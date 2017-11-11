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

default['mailhog']['version'] = '0.2.0'
default['mailhog']['install_method'] = 'binary'

default['mailhog']['binary']['url'] = nil # Set it to override automatical generation

default['mailhog']['binary']['mode'] = 0755
default['mailhog']['binary']['path'] = '/usr/local/bin/MailHog'

default['mailhog']['binary']['prefix_url'] = 'https://github.com/mailhog/MailHog/releases/download/v'
default['mailhog']['binary']['checksum']['linux_386'] = '06fc1d7bf2fced86962ab274d8f1e6c7df74a6ec3c6310aff26792bb93122d98'
default['mailhog']['binary']['checksum']['linux_amd64'] = '11aaae19388d0a6543c935188fcc4157772d852c10be2a5d96168ee23ae6845f'

default['mailhog']['service']['owner'] = 'root'
default['mailhog']['service']['group'] = 'root'

default['mailhog']['smtp']['ip'] = '127.0.0.1'
default['mailhog']['smtp']['port'] = 1025
default['mailhog']['smtp']['outgoing'] = nil

default['mailhog']['api']['ip'] = '0.0.0.0'
default['mailhog']['api']['port'] = 8025
default['mailhog']['ui']['ip'] = '0.0.0.0'
default['mailhog']['ui']['port'] = 8025

default['mailhog']['cors-origin'] = nil
default['mailhog']['hostname'] = 'mailhog.example'

default['mailhog']['storage'] = 'memory'
default['mailhog']['mongodb']['ip'] = '127.0.0.1'
default['mailhog']['mongodb']['port'] = 27017
default['mailhog']['mongodb']['db'] = 'mailhog'
default['mailhog']['mongodb']['collection'] = 'messages'

default['mailhog']['jim']['enable'] = false
default['mailhog']['jim']['accept'] = 0.99
default['mailhog']['jim']['disconnect'] = 0.005
default['mailhog']['jim']['linkspeed']['affect'] = 0.1
default['mailhog']['jim']['linkspeed']['max'] = 10240
default['mailhog']['jim']['linkspeed']['min'] = 1024
default['mailhog']['jim']['reject']['auth'] = 0.05
default['mailhog']['jim']['reject']['recipient'] = 0.05
default['mailhog']['jim']['reject']['sender'] = 0.05