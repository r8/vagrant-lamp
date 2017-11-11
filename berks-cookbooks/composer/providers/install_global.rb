#
# Cookbook Name:: composer
# Resource:: install_global
#
# Copyright 2012-2014, Escape Studios
#

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :install do
  install_global_install
  new_resource.updated_by_last_action(true)
end

action :remove do
  install_global_remove
  new_resource.updated_by_last_action(true)
end

action :update do
  install_global_update
  new_resource.updated_by_last_action(true)
end

def install_global_install
  install_dir = new_resource.install_dir ? new_resource.install_dir : node['composer']['global_install']['install_dir']
  bin_dir = new_resource.bin_dir ? new_resource.bin_dir : node['composer']['global_install']['bin_dir']
  directory install_dir

  composer_project install_dir do
    package new_resource.package
    version new_resource.version
    bin_dir bin_dir
    dev new_resource.dev
    quiet new_resource.quiet
    optimize_autoloader new_resource.optimize_autoloader
    prefer_dist new_resource.prefer_dist
    prefer_source new_resource.prefer_source
    action :require
  end
end

def install_global_remove
  install_dir = new_resource.install_dir ? new_resource.install_dir : node['composer']['global_install']['install_dir']

  composer_project install_dir do
    package new_resource.package
    version new_resource.version
    bin_dir bin_dir
    dev new_resource.dev
    quiet new_resource.quiet
    optimize_autoloader new_resource.optimize_autoloader
    prefer_dist new_resource.prefer_dist
    prefer_source new_resource.prefer_source
    action :remove
  end
end

def install_global_update
  install_dir = new_resource.install_dir ? new_resource.install_dir : node['composer']['global_install']['install_dir']
  bin_dir = new_resource.bin_dir ? new_resource.bin_dir : node['composer']['global_install']['bin_dir']

  composer_project install_dir do
    package new_resource.package
    version new_resource.version
    bin_dir bin_dir
    dev new_resource.dev
    quiet new_resource.quiet
    optimize_autoloader new_resource.optimize_autoloader
    prefer_dist new_resource.prefer_dist
    prefer_source new_resource.prefer_source
    action :update
  end
end
