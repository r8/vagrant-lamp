#
# Cookbook:: mingw
# Library:: _helper
#
# Copyright:: 2016, Chef Software, Inc.
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

module Mingw
  module Helper
    def win_friendly_path(path)
      path.gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || '\\') if path
    end

    def archive_name(source)
      url = ::URI.parse(source)
      ::File.basename(::URI.unescape(url.path))
    end

    def tar_name(source)
      aname = archive_name(source)
      ::File.basename(aname, ::File.extname(aname))
    end
  end
end

Chef::Resource.send(:include, Mingw::Helper)
