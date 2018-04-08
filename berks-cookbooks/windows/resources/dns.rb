#
# Author:: Richard Lavey (richard.lavey@calastone.com)
# Cookbook Name:: windows
# Resource:: dns
#
# Copyright:: 2015, Calastone Ltd.
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

actions :create, :delete
default_action :create

attribute :host_name, kind_of: String, name_property: true, required: true
attribute :record_type, kind_of: String, default: 'A', regex: /^(?:A|CNAME)$/
attribute :dns_server, kind_of: String, default: '.'
attribute :target, kind_of: [Array, String], required: true
attribute :ttl, kind_of: Integer, required: false, default: 0

attr_accessor :exists
