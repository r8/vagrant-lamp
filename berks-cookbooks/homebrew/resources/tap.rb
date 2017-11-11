#
# Author:: Joshua Timberman (<jtimberman@chef.io>)
# Author:: Graeme Mathieson (<mathie@woss.name>)
# Cookbook:: homebrew
# Resources:: tap
#
# Copyright:: 2011-2017, Chef Software, Inc.
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

property :name,
         String,
         name_property: true,
         regex: %r{^[\w-]+(?:\/[\w-]+)+$}
property :url, String
property :full, [TrueClass, FalseClass], default: false

action :tap do
  unless tapped?(new_resource.name)
    execute "tapping #{new_resource.name}" do
      command "/usr/local/bin/brew tap #{full ? '--full' : ''} #{new_resource.name} #{url || ''}"
      environment lazy { { 'HOME' => ::Dir.home(Homebrew.owner), 'USER' => Homebrew.owner } }
      not_if "/usr/local/bin/brew tap | grep #{new_resource.name}"
      user Homebrew.owner
    end
  end
end

action :untap do
  if tapped?(new_resource.name)
    execute "untapping #{new_resource.name}" do
      command "/usr/local/bin/brew untap #{new_resource.name}"
      environment lazy { { 'HOME' => ::Dir.home(Homebrew.owner), 'USER' => Homebrew.owner } }
      only_if "/usr/local/bin/brew tap | grep #{new_resource.name}"
      user Homebrew.owner
    end
  end
end

action_class do
  def tapped?(name)
    tap_dir = name.gsub('/', '/homebrew-')
    ::File.directory?("/usr/local/Homebrew/Library/Taps/#{tap_dir}")
  end
end
