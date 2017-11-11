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

require 'shellwords'

require 'poise_languages/utils/which'


module PoiseLanguages
  module Utils
    include Which
    extend self

    # Default whitelist for {#shelljoin}.
    SHELLJOIN_WHITELIST = [/^2?[><]/]

    # An improved version of Shellwords.shelljoin that doesn't escape a few
    # things.
    #
    # @param cmd [Array<String>] Command array to join.
    # @param whitelist [Array<Regexp>] Array of patterns to whitelist.
    # @return [String]
    def shelljoin(cmd, whitelist: SHELLJOIN_WHITELIST)
      cmd.map do |str|
        if whitelist.any? {|pat| str =~ pat }
          str
        else
          Shellwords.shellescape(str)
        end
      end.join(' ')
    end

    # Convert the executable in a string or array command to an absolute path.
    #
    # @param cmd [String, Array<String>] Command to fix up.
    # @param path [String, nil] Replacement $PATH for executable lookup.
    # @return [String, Array<String>]
    def absolute_command(cmd, path: nil)
      was_array = cmd.is_a?(Array)
      cmd = if was_array
        cmd.dup
      else
        Shellwords.split(cmd)
      end
      # Don't try to touch anything if the first value looks like a flag or a path.
      if cmd.first && !cmd.first.start_with?('-') && !cmd.first.include?(::File::SEPARATOR)
        # If which returns false, just leave it I guess.
        cmd[0] = which(cmd.first, path: path) || cmd.first
      end
      cmd = shelljoin(cmd) unless was_array
      cmd
    end

  end
end
