#
# Cookbook Name:: openssl
# Library:: random_password
# Author:: Seth Vargo <sethvargo@gmail.com>
#
# Copyright 2015, Seth Vargo
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
# rubocop:disable UnusedMethodArgument, Style/RaiseArgs

module OpenSSLCookbook
  module RandomPassword
    # Override the included method to require securerandom if it is not defined.
    # This avoids the need to load the class on each Chef run unless the user is
    # explicitly requiring it.
    def self.included(base)
      require 'securerandom' unless defined?(SecureRandom)
    end

    class InvalidPasswordMode < StandardError
      def initialize(given, acceptable)
        super <<-EOH
The given password mode '#{given}' is not valid. Valid password modes are :hex,
:base64, and :random_bytes!
EOH
      end
    end

    #
    # Generates a random password using {SecureRandom}.
    #
    # @example Generating a random (hex) password (of 20 characters)
    #   random_password #=> "1930e99aa035083bdd93d1d8f11cb7ac8f625c9c"
    #
    # @example Generating a random base64 password that is 50 characters
    #   random_password(mode: :base64, length: 50) #=> "72o5oVbKHHEVYj1nOgFB2EijnzZfnrbfasVuF+oRH8wMgb0QWoYZF/OkrQricp1ENoI="
    #
    # @example Generate a password with a forced encoding
    #   random_password(encoding: "ASCII")
    #
    # @param [Hash] options
    # @option options [Fixnum] :length
    #   the number of bits to use in the password
    # @option options [Symbol] :mode
    #   the type of random password to generate - valid values are
    #   `:hex`, `:base64`, or `:random_bytes`
    # @option options [String, Symbol, Constant] :encoding
    #   the encoding to force (default is "UTF-8")
    #
    # @return [String]
    #
    def random_password(options = {})
      length   = options[:length] || 20
      mode     = options[:mode] || :hex
      encoding = options[:encoding] || 'UTF-8'

      # Convert to a "proper" length, since the size is actually in bytes
      length = case mode
               when :hex
                 length / 2
               when :base64
                 length * 3 / 4
               when :random_bytes
                 length
               else
                 fail InvalidPasswordMode.new(mode)
               end

      SecureRandom.send(mode, length).force_encoding(encoding)
    end
  end
end
