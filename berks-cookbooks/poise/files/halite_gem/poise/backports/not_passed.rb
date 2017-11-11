#
# Copyright 2015-2016, Noah Kantrowitz
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

begin
  require 'chef/constants'
rescue LoadError
  # This space left intentionally blank.
end


module Poise
  module Backports
    # A sentinel value for optional arguments where nil is a valid value.
    # @since 2.3.0
    # @!parse NOT_PASSED = Object.new
    NOT_PASSED = if defined?(Chef::NOT_PASSED)
       Chef::NOT_PASSED
    else
      # Copyright 2015-2016, Chef Software Inc.
      # Used under Apache License, Version 2.0.
      Object.new.tap do |not_passed|
        def not_passed.to_s
          "NOT_PASSED"
        end
        def not_passed.inspect
          to_s
        end
        not_passed.freeze
      end
    end

  end

  # An alias to {Backports::NOT_PASSED} to avoid typing so much.
  #
  # @since 2.3.0
  # @see Backports::NOT_PASSED
  NOT_PASSED = Backports::NOT_PASSED
end
