# Encoding: utf-8

require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'

at_exit { ChefSpec::Coverage.report! }

RSpec.configure do |config|
  config.version = '14.04'
  config.platform = 'ubuntu'
end
