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


module PoiseLanguages
  module Utils
    # Replacement module for Chef::Mixin::Which with a slight improvement.
    #
    # @since 1.0.0
    # @see Which#which
    module Which
      extend self

      # A replacement for Chef::Mixin::Which#which that allows using something
      # other than an environment variable if needed.
      #
      # @param cmd [String] Executable to search for.
      # @param extra_path [Array<String>] Extra directories to always search.
      # @param path [String, nil] Replacement $PATH value.
      # @return [String, false]
      def which(cmd, extra_path: %w{/bin /usr/bin /sbin /usr/sbin}, path: nil)
        # If it was already absolute, just return that.
        return cmd if cmd =~ /^(\/|([a-z]:)?\\)/i
        # Allow passing something other than the real env var.
        path ||= ENV['PATH']
        # Based on Chef::Mixin::Which#which
        # Copyright 2010-2017, Chef Softare, Inc.
        paths = path.split(File::PATH_SEPARATOR) + extra_path
        paths.each do |candidate_path|
          filename = ::File.join(candidate_path, cmd)
          return filename if ::File.executable?(filename)
        end
        false
      end

    end
  end
end
