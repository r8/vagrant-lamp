include_recipe "build-essential"
include_recipe "nodejs"
include_recipe "nodejs::npm"

# Set npm global prefix
execute 'npm-set-prefix' do
  command 'npm config set prefix /usr/local'
end

# Install npm modules
%w{ coffee-script grunt-cli bower yo less csslint }.each do |a_package|
  nodejs_npm a_package
end
