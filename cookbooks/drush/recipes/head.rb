# Author:: Mark Sonnabaum <mark.sonnabaum@acquia.com>
# Cookbook Name::  drush
# Recipe:: default
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

case node[:platform]
when "debian", "ubuntu"
  git "/usr/share/drush" do
    repository "git://git.drupal.org/project/drush.git"
    reference "7.x-5.x"
    action :sync
  end
  
  bash "make-drush-symlink" do
    code <<-EOH
    (ln -s /usr/share/drush/drush /usr/bin/drush)
    EOH
    not_if { File.exists?("/usr/bin/drush") }
    only_if { File.exists?("/usr/share/drush/drush") }
  end

  bash "install-console-table" do
    code <<-EOH
    (pear install Console_Table)
    EOH
    not_if "pear list| grep Console_Table"
  end
end
