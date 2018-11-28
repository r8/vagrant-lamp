#
# Cookbook:: build-essential
# resource:: build_essential
#
# Copyright:: 2008-2018, Chef Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

chef_version_for_provides '< 14.0' if respond_to?(:chef_version_for_provides)
provides :build_essential
resource_name :build_essential

property :compile_time, [true, false], default: false

action :install do
  case node['platform_family']
  when 'debian'
    package %w( autoconf binutils-doc bison build-essential flex gettext ncurses-dev )
  when 'amazon', 'fedora', 'rhel'
    package %w( autoconf bison flex gcc gcc-c++ gettext kernel-devel make m4 ncurses-devel patch )

    # Ensure GCC 4 is available on older pre-6 EL
    package %w( gcc44 gcc44-c++ ) if !platform?('amazon') && node['platform_version'].to_i < 6
  when 'freebsd'
    package 'devel/gmake'
    package 'devel/autoconf'
    package 'devel/m4'
    package 'devel/gettext'
  when 'mac_os_x'
    xcode_command_line_tools 'install'
  when 'omnios'
    package 'developer/gcc48'
    package 'developer/object-file'
    package 'developer/linker'
    package 'developer/library/lint'
    package 'developer/build/gnu-make'
    package 'system/header'
    package 'system/library/math/header-math'

    # Per OmniOS documentation, the gcc bin dir isn't in the default
    # $PATH, so add it to the running process environment
    # http://omnios.omniti.com/wiki.php/DevEnv
    ENV['PATH'] = "#{ENV['PATH']}:/opt/gcc-4.7.2/bin"
  when 'solaris2'
    if node['platform_version'].to_f == 5.10
      Chef::Log.warn('build-essential does not support Solaris 10. You will need to install SUNWbison, SUNWgcc, SUNWggrp, SUNWgmake, and SUNWgtar from the Solaris DVD')
    elsif node['platform_version'].to_f == 5.11
      package 'autoconf'
      package 'automake'
      package 'bison'
      package 'gnu-coreutils'
      package 'flex'
      # lock gcc versions because we don't use 5 yet
      %w(gcc gcc-c gcc-c++).each do |pkg|
        package pkg do # ~FC009
          accept_license true
          version '4.8.2'
        end
      end
      package 'gnu-grep'
      package 'gnu-make'
      package 'gnu-patch'
      package 'gnu-tar'
      package 'make'
      package 'pkg-config'
      package 'ucb'
    end
  when 'smartos'
    package 'autoconf'
    package 'binutils'
    package 'build-essential'
    package 'gcc47'
    package 'gmake'
    package 'pkg-config'
  when 'suse'
    package %w( autoconf bison flex gcc gcc-c++ kernel-default-devel make m4 )
    package %w( gcc48 gcc48-c++ ) if node['platform_version'].to_i < 12
  when 'windows'
    include_recipe 'build-essential::_windows'
  else
    Chef::Log.warn <<-EOH
  A build-essential recipe does not exist for '#{node['platform_family']}'. This
  means the build-essential cookbook does not have support for the
  #{node['platform_family']} family. If you are not compiling gems with native
  extensions or building packages from source, this will likely not affect you.
  EOH
  end
end

# this resource forces itself to run at compile_time
def after_created
  return unless compile_time
  Array(action).each do |action|
    run_action(action)
  end
end
