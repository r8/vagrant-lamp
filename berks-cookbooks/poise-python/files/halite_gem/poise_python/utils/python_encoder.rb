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

require 'json'


module PoisePython
  module Utils
    # Convert Ruby data structures to a Python literal. Overall similar to JSON
    # but just different enough that I need to write this. Thanks Obama.
    #
    # @since 1.0.0
    # @api private
    class PythonEncoder
      def initialize(root, depth_limit: 100)
        @root = root
        @depth_limit = depth_limit
      end

      def encode
        encode_obj(@root, 0)
      end

      private

      def encode_obj(obj, depth)
        raise ArgumentError.new("Depth limit exceeded") if depth > @depth_limit
        case obj
        when Hash
          encode_hash(obj, depth)
        when Array
          encode_array(obj, depth)
        when true
          'True'
        when false
          'False'
        when nil
          'None'
        else
          obj.to_json
        end
      end

      def encode_hash(obj, depth)
        middle = obj.map do |key, value|
          "#{encode_obj(key, depth+1)}:#{encode_obj(value, depth+1)}"
        end
        "{#{middle.join(',')}}"
      end

      def encode_array(obj, depth)
        middle = obj.map do |value|
          encode_obj(value, depth+1)
        end
        "[#{middle.join(',')}]"
      end

    end
  end
end
