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

property :share_name, String, name_property: true
property :path, String
property :description, String, default: ''
property :full_users, Array, default: []
property :change_users, Array, default: []
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
      converge_by('Removing previous share') do
        delete_share
      end
    end
    converge_by("Creating share #{current_resource.share_name}") do
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
    !(current_resource.send(permission_type.to_sym) - new_resource.send(permission_type.to_sym).map(&:downcase)).empty? &&
      !(new_resource.send(permission_type.to_sym).map(&:downcase) - current_resource.send(permission_type.to_sym)).empty?
  end

  def find_share_by_name(name)
    wmi = WIN32OLE.connect('winmgmts://')
    shares = wmi.ExecQuery("SELECT * FROM Win32_Share WHERE name = '#{name}'")
    shares.Count == 0 ? nil : shares.ItemIndex(0)
  end

  def delete_share
    find_share_by_name(new_resource.share_name).delete
  end

  def create_share
    raise "#{new_resource.path} is missing or not a directory" unless ::File.directory? new_resource.path
    new_share_script = <<-EOH
      $share = [wmiclass]"\\\\#{ENV['COMPUTERNAME']}\\root\\CimV2:Win32_Share"
      $result=$share.Create('#{new_resource.path}',
                            '#{new_resource.share_name}',
                            0,
                            16777216,
                            '#{new_resource.description}',
                            $null,
                            $null)
      exit $result.returnValue
    EOH
    r = powershell_out new_share_script
    message = case r.exitstatus
              when 2
                '2 : Access Denied'
              when 8
                '8 : Unknown Failure'
              when 9
                '9 : Invalid Name'
              when 10
                '10 : Invalid Level'
              when 21
                '21 : Invalid Parameter'
              when 22
                '22 : Duplicate Share'
              when 23
                '23 : Redirected Path'
              when 24
                '24 : Unknown Device or Directory'
              when 25
                '25 : Net Name Not Found'
              else
                r.exitstatus.to_s
              end

    raise "Could not create share.  Win32_Share.create returned #{message}" if r.error?
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
        $account = get-wmiobject Win32_Account -filter "Name like '$Name' and Domain like '$Domain'"
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
