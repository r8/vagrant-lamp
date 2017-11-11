#
# Cookbook Name:: redisio
# Resource::sentinel
#
# Copyright 2013, Rackspace Hosting <ryan.cleere@rackspace.com>
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
actions :run

default_action :run

# Configuration attributes
attribute :version, kind_of: String
attribute :base_piddir, kind_of: String, default: '/var/run/redis'
attribute :user, kind_of: String, default: 'redis'

attribute :sentinel_defaults, kind_of: Hash
attribute :sentinels, kind_of: Array
