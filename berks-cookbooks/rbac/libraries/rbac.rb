# This module is used to retain state during the course of a chef
# run. The LWRPs in the cookbook modify a global hash in this module,
# and at the end of the chef run if user authorizations change they
# are written out into the system.
#
module RBAC
  def self.authorizations
    @authorizations ||= {}
  end

  def self.add_authorization(username, auth)
    authorizations[username] ||= []
    authorizations[username] << auth
  end
end
