include_recipe "build-essential"
include_recipe "nodejs"
include_recipe "npm"

# Install npm modules
%w{ coffee-script grunt-cli bower yo less csslint }.each do |a_package|
  npm_package a_package
end
