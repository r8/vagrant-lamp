#
# Author:: Artur Melo (<artur.melo@beubi.com>)
# Cookbook:: php
# Recipe:: module_imap
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

pkg = value_for_platform(
  %w(centos redhat scientific fedora amazon oracle) => {
    'default' => 'php-imap',
  },
  'default' => 'php5-imap'
)

package pkg do
  action :install
end
