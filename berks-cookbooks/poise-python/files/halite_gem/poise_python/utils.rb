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

require 'poise_python/error'


module PoisePython
  # Helper methods for Python-related things.
  #
  # @since 1.0.0
  module Utils
    autoload :PythonEncoder, 'poise_python/utils/python_encoder'
    extend self

    # Convert an object to a Python literal.
    #
    # @param obj [Object] Ovject to convert.
    # @return [String]
    def to_python(obj)
      PythonEncoder.new(obj).encode
    end

    # Convert path to a Python dotted module name.
    #
    # @param path [String] Path to the file. If base is not given, this must be
    #   a relative path.
    # @param base [String] Optional base path to treat the file as relative to.
    # @return [String]
    def path_to_module(path, base=nil)
      if base
        path = ::File.expand_path(path, base)
        raise PoisePython::Error.new("Path #{path} is not inside base path #{base}") unless path.start_with?(base)
        path = path[base.length+1..-1]
      end
      path = path[0..-4] if path.end_with?('.py')
      path.gsub(/#{::File::SEPARATOR}/, '.')
    end

    # Convert a Python dotted module name to a path.
    #
    # @param mod [String] Dotted module name.
    # @param base [String] Optional base path to treat the file as relative to.
    # @return [String]
    def module_to_path(mod, base=nil)
      path = mod.gsub(/\./, ::File::SEPARATOR) + '.py'
      path = ::File.join(base, path) if base
      path
    end
  end
end
