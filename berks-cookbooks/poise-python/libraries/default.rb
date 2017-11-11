#
# Copyright 2015-2017, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

raise 'Halite is not compatible with no_lazy_load false, please set no_lazy_load true in your Chef configuration file.' unless Chef::Config[:no_lazy_load]
$LOAD_PATH << File.expand_path('../../files/halite_gem', __FILE__)
require "poise_python/cheftie"
