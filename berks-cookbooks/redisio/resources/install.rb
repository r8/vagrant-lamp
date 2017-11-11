#
# Cookbook Name:: redisio
# Resource::install
#
# Copyright 2013, Brian Bianco <brian.bianco@gmail.com>
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

# Installation attributes
attribute :version, kind_of: String
attribute :download_url, kind_of: String
attribute :download_dir, kind_of: String, default: Chef::Config[:file_cache_path]
attribute :artifact_type, kind_of: String, default: 'tar.gz'
attribute :base_name, kind_of: String, default: 'redis-'
attribute :safe_install, kind_of: [TrueClass, FalseClass], default: true

attribute :install_dir, kind_of: String, default: nil
