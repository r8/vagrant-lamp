module OpenSSLCookbook
  # Helper functions for the OpenSSL cookbook.
  module Helpers
    def self.included(_base)
      require 'openssl' unless defined?(OpenSSL)
    end

    # Path helpers
    def get_key_filename(cert_filename)
      cert_file_path, cert_filename = ::File.split(cert_filename)
      cert_filename = ::File.basename(cert_filename, ::File.extname(cert_filename))
      cert_file_path + ::File::SEPARATOR + cert_filename + '.key'
    end

    # Validation helpers
    def key_length_valid?(number)
      number >= 1024 && number & (number - 1) == 0
    end

    def dhparam_pem_valid?(dhparam_pem_path)
      # Check if the dhparam.pem file exists
      # Verify the dhparam.pem file contains a key
      return false unless File.exist?(dhparam_pem_path)
      dhparam = OpenSSL::PKey::DH.new File.read(dhparam_pem_path)
      dhparam.params_ok?
    end

    def key_file_valid?(key_file_path, key_password = nil)
      # Check if the key file exists
      # Verify the key file contains a private key
      return false unless File.exist?(key_file_path)
      key = OpenSSL::PKey::RSA.new File.read(key_file_path), key_password
      key.private?
    end

    # Generators
    def gen_dhparam(key_length, generator)
      fail ArgumentError, 'Key length must be a power of 2 greater than or equal to 1024' unless key_length_valid?(key_length)
      fail TypeError, 'Generator must be an integer' unless generator.is_a?(Integer)

      OpenSSL::PKey::DH.new(key_length, generator)
    end

    def gen_rsa_key(key_length)
      fail ArgumentError, 'Key length must be a power of 2 greater than or equal to 1024' unless key_length_valid?(key_length)

      OpenSSL::PKey::RSA.new(key_length)
    end

    # Key manipulation helpers
    # Returns a pem string
    def encrypt_rsa_key(rsa_key, key_password)
      fail TypeError, 'rsa_key must be a Ruby OpenSSL::PKey::RSA object' unless rsa_key.is_a?(OpenSSL::PKey::RSA)
      fail TypeError, 'RSA key password must be a string' unless key_password.is_a?(String)

      cipher = OpenSSL::Cipher::Cipher.new('des3')
      rsa_key.to_pem(cipher, key_password)
    end
  end
end
