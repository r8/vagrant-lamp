#
# Author:: Greg Zapp (<greg.zapp@gmail.com>)
# Cookbook:: windows
# Provider:: feature_powershell
#

property :feature_name, [Array, String], name_attribute: true
property :source, String
property :all, [true, false], default: false
property :timeout, Integer, default: 600
property :management_tools, [true, false], default: false

include Chef::Mixin::PowershellOut
include Windows::Helper

action :remove do
  if installed?
    converge_by("remove Windows feature #{new_resource.feature_name}") do
      cmd = powershell_out!("#{remove_feature_cmdlet} #{to_array(new_resource.feature_name).join(',')}", timeout: new_resource.timeout)
      Chef::Log.info(cmd.stdout)
    end
  end
end

action :delete do
  if available?
    converge_by("delete Windows feature #{new_resource.feature_name} from the image") do
      cmd = powershell_out!("Uninstall-WindowsFeature #{to_array(new_resource.feature_name).join(',')} -Remove", timeout: new_resource.timeout)
      Chef::Log.info(cmd.stdout)
    end
  end
end

action_class do
  def install_feature_cmdlet
    node['os_version'].to_f < 6.2 ? 'Import-Module ServerManager; Add-WindowsFeature' : 'Install-WindowsFeature'
  end

  def remove_feature_cmdlet
    node['os_version'].to_f < 6.2 ? 'Import-Module ServerManager; Remove-WindowsFeature' : 'Uninstall-WindowsFeature'
  end

  def installed?
    @installed ||= begin
      cmd = if node['os_version'].to_f < 6.2
              powershell_out("Import-Module ServerManager; @(Get-WindowsFeature #{to_array(new_resource.feature_name).join(',')} | ?{$_.Installed -ne $TRUE}).count", timeout: new_resource.timeout)
            else
              powershell_out("@(Get-WindowsFeature #{to_array(new_resource.feature_name).join(',')} | ?{$_.InstallState -ne \'Installed\'}).count", timeout: new_resource.timeout)
            end
      cmd.stderr.empty? && cmd.stdout.chomp.to_i == 0
    end
  end

  def available?
    @available ||= begin
      cmd = if node['os_version'].to_f < 6.2
              powershell_out("Import-Module ServerManager; @(Get-WindowsFeature #{to_array(new_resource.feature_name).join(',')}).count", timeout: new_resource.timeout)
            else
              powershell_out("@(Get-WindowsFeature #{to_array(new_resource.feature_name).join(',')} | ?{$_.InstallState -ne \'Removed\'}).count", timeout: new_resource.timeout)
            end
      cmd.stderr.empty? && cmd.stdout.chomp.to_i > 0
    end
  end
end

action :install do
  Chef::Log.warn("Requested feature #{new_resource.feature_name} is not available on this system.") unless available?
  unless !available? || installed?
    converge_by("install Windows feature #{new_resource.feature_name}") do
      addsource = new_resource.source ? "-Source \"#{new_resource.source}\"" : ''
      addall = new_resource.all ? '-IncludeAllSubFeature' : ''
      addmanagementtools = new_resource.management_tools ? '-IncludeManagementTools' : ''
      cmd = if node['os_version'].to_f < 6.2
              powershell_out!("#{install_feature_cmdlet} #{to_array(new_resource.feature_name).join(',')} #{addall}", timeout: new_resource.timeout)
            else
              powershell_out!("#{install_feature_cmdlet} #{to_array(new_resource.feature_name).join(',')} #{addsource} #{addall} #{addmanagementtools}", timeout: new_resource.timeout)
            end
      Chef::Log.info(cmd.stdout)
    end
  end
end
