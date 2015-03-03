# encoding: utf-8

action :install do
  pkg_id = new_resource.name
  pkg_id += "@#{new_resource.version}" if new_resource.version
  execute "install NPM package #{new_resource.name}" do
    command "npm -g install #{pkg_id}"
    not_if "npm -g ls 2> /dev/null | grep '^[├└]─[─┬] #{pkg_id}'"
  end
end

action :install_local do
  path = new_resource.path if new_resource.path
  pkg_id = new_resource.name
  pkg_id += "@#{new_resource.version}" if new_resource.version
  execute "install NPM package #{new_resource.name} into #{path}" do
    cwd path
    command "npm install #{pkg_id}"
    not_if "cd #{path} && npm ls 2> /dev/null | grep '^[├└]─[─┬] #{pkg_id}'"
  end
end

action :install_from_json do
  path = new_resource.path
  cmd  = "npm install"
  execute "install NPM packages from package.json at #{path}" do
    cwd path
    command cmd
  end
end

action :uninstall do
  pkg_id = new_resource.name
  pkg_id += "@#{new_resource.version}" if new_resource.version
  execute "uninstall NPM package #{new_resource.name}" do
    command "npm -g uninstall #{pkg_id}"
    only_if "npm -g ls 2> /dev/null | grep '^[├└]─[─┬] #{pkg_id}'"
  end
end

action :uninstall_local do
  path = new_resource.path if new_resource.path
  pkg_id = new_resource.name
  pkg_id += "@#{new_resource.version}" if new_resource.version
  execute "uninstall NPM package #{new_resource.name} from #{path}" do
    cwd path
    command "npm uninstall #{pkg_id}"
    only_if "cd #{path} && npm ls 2> /dev/null | grep '^[├└]─[─┬] #{pkg_id}'"
  end
end
