# -*- coding: utf-8 -*-
#
# Author:: Sölvi Páll Ásgeirsson (<solvip@gmail.com>), Richard Lavey (richard.lavey@calastone.com)
# Cookbook:: windows
# Resource:: share
#
# Copyright:: 2014-2017, Sölvi Páll Ásgeirsson.
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

# Specifies a name for the SMB share. The name may be composed of any valid file name characters, but must be less than 80 characters long. The names pipe and mailslot are reserved for use by the computer.
property :share_name, String, name_property: true

# Specifies the path of the location of the folder to share. The path must be fully qualified. Relative paths or paths that contain wildcard characters are not permitted.
property :path, String

# Specifies an optional description of the SMB share. A description of the share is displayed by running the Get-SmbShare cmdlet. The description may not contain more than 256 characters.
property :description, String, default: ''

# Specifies which accounts are granted full permission to access the share. Use a comma-separated list to specify multiple accounts. An account may not be specified more than once in the FullAccess, ChangeAccess, or ReadAccess parameter lists, but may be specified once in the FullAccess, ChangeAccess, or ReadAccess parameter list and once in the NoAccess parameter list.
property :full_users, Array, default: []

# Specifies which users are granted modify permission to access the share
property :change_users, Array, default: []

# Specifies which users are granted read permission to access the share. Multiple users can be specified by supplying a comma-separated list.
property :read_users, Array, default: []

include Windows::Helper
include Chef::Mixin::PowershellOut

require 'win32ole' if RUBY_PLATFORM =~ /mswin|mingw32|windows/

ACCESS_FULL = 2_032_127
ACCESS_CHANGE = 1_245_631
ACCESS_READ = 1_179_817

action :create do
  raise 'No path property set' unless new_resource.path

  if different_path?
    unless current_resource.path.nil? || current_resource.path.empty?
      converge_by("Removing previous share #{new_resource.share_name}") do
        delete_share
      end
    end
    converge_by("Creating share #{new_resource.share_name}") do
      create_share
    end
  end

  if different_members?(:full_users) ||
     different_members?(:change_users) ||
     different_members?(:read_users) ||
     different_description?
    converge_by("Setting permissions and description for #{new_resource.share_name}") do
      set_share_permissions
    end
  end
end

action :delete do
  if !current_resource.path.nil? && !current_resource.path.empty?
    converge_by("Deleting #{current_resource.share_name}") do
      delete_share
    end
  else
    Chef::Log.debug("#{current_resource.share_name} does not exist - nothing to do")
  end
end

load_current_value do |desired|
  wmi = WIN32OLE.connect('winmgmts://')
  shares = wmi.ExecQuery("SELECT * FROM Win32_Share WHERE name = '#{desired.share_name}'")
  existing_share = shares.Count == 0 ? nil : shares.ItemIndex(0)

  description ''
  unless existing_share.nil?
    path existing_share.Path
    description existing_share.Description
  end

  perms = share_permissions name
  unless perms.nil?
    full_users perms[:full_users]
    change_users perms[:change_users]
    read_users perms[:read_users]
  end
end

def share_permissions(name)
  wmi = WIN32OLE.connect('winmgmts://')
  shares = wmi.ExecQuery("SELECT * FROM Win32_LogicalShareSecuritySetting WHERE name = '#{name}'")

  # The security descriptor is an output parameter
  sd = nil
  begin
    shares.ItemIndex(0).GetSecurityDescriptor(sd)
    sd = WIN32OLE::ARGV[0]
  rescue WIN32OLERuntimeError
    Chef::Log.warn('Failed to retrieve any security information about the share.')
  end

  read = []
  change = []
  full = []

  unless sd.nil?
    sd.DACL.each do |dacl|
      trustee = "#{dacl.Trustee.Domain}\\#{dacl.Trustee.Name}".downcase
      case dacl.AccessMask
      when ACCESS_FULL
        full.push(trustee)
      when ACCESS_CHANGE
        change.push(trustee)
      when ACCESS_READ
        read.push(trustee)
      else
        Chef::Log.warn "Unknown access mask #{dacl.AccessMask} for user #{trustee}. This will be lost if permissions are updated"
      end
    end
  end

  {
    full_users: full,
    change_users: change,
    read_users: read,
  }
end

action_class do
  def description_exists?(resource)
    !resource.description.nil?
  end

  def different_description?
    if description_exists?(new_resource) && description_exists?(current_resource)
      new_resource.description.casecmp(current_resource.description) != 0
    else
      description_exists?(new_resource) || description_exists?(current_resource)
    end
  end

  def different_path?
    return true if current_resource.path.nil?
    win_friendly_path(new_resource.path).casecmp(win_friendly_path(current_resource.path)) != 0
  end

  def different_members?(permission_type)
    !(current_resource.send(permission_type.to_sym) - new_resource.send(permission_type.to_sym).map(&:downcase)).empty? ||
      !(new_resource.send(permission_type.to_sym).map(&:downcase) - current_resource.send(permission_type.to_sym)).empty?
  end

  def delete_share
    powershell_out("Remove-SmbShare -Name \"#{new_resource.share_name}\" -Description \"#{new_resource.description}\" -Confirm")
  end

  def create_share
    raise "#{new_resource.path} is missing or not a directory" unless ::File.directory? new_resource.path

    powershell_out("New-SmbShare -Name \"#{new_resource.share_name}\" -Path \"#{new_resource.path}\" -Confirm")
  end

  # set_share_permissions - Enforce the share permissions as dictated by the resource attributes
  def set_share_permissions
    share_permissions_script = <<-EOH
      Function New-SecurityDescriptor
      {
        param (
          [array]$ACEs
        )
        #Create SeCDesc object
        $SecDesc = ([WMIClass] "\\\\$env:ComputerName\\root\\cimv2:Win32_SecurityDescriptor").CreateInstance()

        foreach ($ACE in $ACEs )
        {
          $SecDesc.DACL += $ACE.psobject.baseobject
        }

        #Return the security Descriptor
        return $SecDesc
      }

      Function New-ACE
      {
        param  (
          [string] $Name,
          [string] $Domain,
          [string] $Permission = "Read"
        )
        #Create the Trusteee Object
        $Trustee = ([WMIClass] "\\\\$env:computername\\root\\cimv2:Win32_Trustee").CreateInstance()
        $account = get-wmiobject Win32_Account -filter "Name = '$Name' and Domain = '$Domain'"
        $accountSID = [WMI] "\\\\$env:ComputerName\\root\\cimv2:Win32_SID.SID='$($account.sid)'"

        $Trustee.Domain = $Domain
        $Trustee.Name = $Name
        $Trustee.SID = $accountSID.BinaryRepresentation

        #Create ACE (Access Control List) object.
        $ACE = ([WMIClass] "\\\\$env:ComputerName\\root\\cimv2:Win32_ACE").CreateInstance()
        switch ($Permission)
        {
          "Read" 		 { $ACE.AccessMask = 1179817 }
          "Change"  {	$ACE.AccessMask = 1245631 }
          "Full"		   { $ACE.AccessMask = 2032127 }
          default { throw "$Permission is not a supported permission value. Possible values are 'Read','Change','Full'" }
        }

        $ACE.AceFlags = 3
        $ACE.AceType = 0
        $ACE.Trustee = $Trustee

        $ACE
      }

      $dacl_array = @()

    EOH
    new_resource.full_users.each do |user|
      share_permissions_script += user_to_ace(user, 'Full')
    end

    new_resource.change_users.each do |user|
      share_permissions_script += user_to_ace(user, 'Change')
    end

    new_resource.read_users.each do |user|
      share_permissions_script += user_to_ace(user, 'Read')
    end

    share_permissions_script += <<-EOH

      $dacl = New-SecurityDescriptor -Aces $dacl_array

      $share = get-wmiobject win32_share -filter 'Name like "#{new_resource.share_name}"'
      $return = $share.SetShareInfo($null, '#{new_resource.description}', $dacl)
      exit $return.returnValue
    EOH
    r = powershell_out(share_permissions_script)
    raise "Could not set share permissions.  Win32_Share.SedtShareInfo returned #{r.exitstatus}" if r.error?
  end

  def user_to_ace(fully_qualified_user_name, access)
    domain, user = fully_qualified_user_name.split('\\')
    unless domain && user
      raise "Invalid user entry #{fully_qualified_user_name}.  The user names must be specified as 'DOMAIN\\user'"
    end
    "\n$dacl_array += new-ace -Name '#{user}' -domain '#{domain}' -permission '#{access}'"
  end
end
