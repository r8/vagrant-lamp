#
# Author:: Jared Kauppila (<jared@kauppi.la>)
# Cookbook:: windows
# Resource:: user_privilege
#

property :principal, String, name_property: true
property :privilege, [Array, String], required: true, coerce: proc { |v| [*v].sort }

action :add do
  ([*new_resource.privilege] - [*current_resource.privilege]).each do |user_right|
    converge_by("adding user privilege #{user_right}") do
      Chef::ReservedNames::Win32::Security.add_account_right(new_resource.principal, user_right)
    end
  end
end

action :remove do
  curr_res_privilege = current_resource.privilege
  new_res_privilege = new_resource.privilege
  missing_res_privileges = (new_res_privilege - curr_res_privilege)

  if missing_res_privileges
    Chef::Log.info("Privilege: #{missing_res_privileges.join(', ')} not present. Unable to delete")
  end

  (new_res_privilege - missing_res_privileges).each do |user_right|
    converge_by("removing user privilege #{user_right}") do
      Chef::ReservedNames::Win32::Security.remove_account_right(new_resource.principal, user_right)
    end
  end
end

load_current_value do |desired|
  privilege Chef::ReservedNames::Win32::Security.get_account_right(desired.principal)
end
