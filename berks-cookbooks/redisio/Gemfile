source 'https://rubygems.org'

# Uncomment these lines if you want to live on the Edge:
#
# group :development do
#   gem "berkshelf", github: "berkshelf/berkshelf"
#   gem "vagrant", github: "mitchellh/vagrant", tag: "v1.5.2"
# end
#
# group :plugins do
#   gem "vagrant-berkshelf", github: "berkshelf/vagrant-berkshelf"
#   gem "vagrant-omnibus", github: "schisamo/vagrant-omnibus"
# end

group :testing do
  gem 'berkshelf'
  gem 'chefspec'
  gem 'foodcritic'
  gem 'rake'
  gem 'rubocop'
end

group :travis_integration do
  gem 'kitchen-dokken'
end

group :integration do
  gem 'busser-serverspec'
  gem 'kitchen-vagrant'
  gem 'serverspec'
  gem 'test-kitchen'
  gem 'vagrant-wrapper'
end
