require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.platform = 'windows'
  config.version = '2012R2'
  ENV['ProgramFiles(x86)'] = 'C:\Program Files (x86)' # assume 64bit OS
  ENV['ProgramFiles'] = 'C:\Program Files'
  ENV['WINDIR'] = 'C:\Windows'
  ENV['SYSTEMDRIVE'] = 'C:\\'
end
