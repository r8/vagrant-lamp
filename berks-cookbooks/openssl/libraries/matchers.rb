if defined?(ChefSpec)
  def create_x509_certificate(name)
    ChefSpec::Matchers::ResourceMatcher.new(:openssl_x509, :create, name)
  end

  def create_dhparam_pem(name)
    ChefSpec::Matchers::ResourceMatcher.new(:openssl_dhparam, :create, name)
  end

  def create_rsa_key(name)
    ChefSpec::Matchers::ResourceMatcher.new(:openssl_rsa_key, :create, name)
  end
end
