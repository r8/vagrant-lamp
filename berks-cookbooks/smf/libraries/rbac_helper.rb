module SMFManifest
  # Helper methods for determining whether work needs to be done
  # with respect to assigning RBAC values to a service.
  class RBACHelper < SMFManifest::Helper
    include Chef::Mixin::ShellOut

    def authorization_set?
      current_authorization == authorization
    end

    def value_authorization_set?
      current_value_authorization == value_authorization
    end

    def current_authorization
      shell_out("svcprop -p general/action_authorization #{resource.name}").stdout.chomp
    end

    def current_value_authorization
      shell_out("svcprop -p general/value_authorization #{resource.name}").stdout.chomp
    end

    def authorization
      "solaris.smf.manage.#{resource.authorization_name}"
    end

    def value_authorization
      "solaris.smf.value.#{resource.authorization_name}"
    end
  end
end
