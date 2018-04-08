node['nodejs']['npm_packages'].each do |pkg|
  pkg_action = pkg.key?('action') ? pkg['action'] : :install
  f = npm_package "nodejs_npm-#{pkg['name']}-#{pkg_action}" do
    action :nothing
    package pkg['name']
  end
  pkg.each do |key, value|
    f.send(key, value) unless key == 'name' || key == 'action'
  end
  f.action(pkg_action)
end if node['nodejs'].key?('npm_packages')
