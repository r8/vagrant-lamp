#
# Cookbook Name:: composer
# Resource:: project
#
# Copyright (c) 2016, David Joos
#

actions :install, :single, :require, :update, :dump_autoload, :remove
default_action :install

attribute :project_dir, :kind_of => String, :name_attribute => true
attribute :vendor, :kind_of => String, :default => nil
attribute :package, :kind_of => String, :default => nil
attribute :version, :kind_of => String, :default => nil
attribute :dev, :kind_of => [TrueClass, FalseClass], :default => false
attribute :quiet, :kind_of => [TrueClass, FalseClass], :default => true
attribute :optimize_autoloader, :kind_of => [TrueClass, FalseClass], :default => false
attribute :prefer_dist, :kind_of => [TrueClass, FalseClass], :default => false
attribute :prefer_source, :kind_of => [TrueClass, FalseClass], :default => false
attribute :bin_dir, :kind_of => String, :default => 'vendor/bin'
attribute :user, :kind_of => String, :default => 'root'
attribute :group, :kind_of => String, :default => 'root'
attribute :umask, :kind_of => [String, Integer], :default => '0002'
attribute :environment, :kind_of => Hash, :default => {}

def initialize(*args)
  super
  @action = :install
end
