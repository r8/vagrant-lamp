class Chef
  # Public: This class provides helpers for retrieving passwords from encrypted
  # data bags
  class EncryptedPasswords
    attr_accessor :node, :bag, :secret_file

    def initialize(node, bag = "passwords")
      @node = node
      @bag = bag
      @secret_file = node["percona"]["encrypted_data_bag_secret_file"]
      @mysql_item = node["percona"]["encrypted_data_bag_item_mysql"]
      @system_item = node["percona"]["encrypted_data_bag_item_system"]
    end

    # helper for passwords
    def find_password(item, user, default = nil)
      begin
        # attribute that controls use of chef-vault or encrypted data bags
        vault = node["percona"]["use_chef_vault"]
        # load password from the vault
        pwds = ChefVault::Item.load(bag, item) if vault
        # load the encrypted data bag item, using a secret if specified
        pwds = Chef::EncryptedDataBagItem.load(@bag, item, secret) unless vault
        # now, let's look for the user password
        password = pwds[user]
      rescue
        Chef::Log.info("Unable to load password for #{user}, #{item},"\
                       "fall back to non-encrypted password")
      end
      # password will be nil if no encrypted data bag was loaded
      # fall back to the attribute on this node
      password || default
    end

    # mysql root
    def root_password
      find_password @mysql_item, "root", node_server["root_password"]
    end

    # debian script user password
    def debian_password
      find_password(
        @system_item, node_server["debian_username"],
        node_server["debian_password"]
      )
    end

    # ?
    def old_passwords
      find_password @mysql_item, "old_passwords", node_server["old_passwords"]
    end

    # password for user responsbile for replicating in master/slave environment
    def replication_password
      find_password(
        @mysql_item, "replication", node_server["replication"]["password"]
      )
    end

    # password for user responsbile for running xtrabackup
    def backup_password
      backup = node["percona"]["backup"]
      find_password @mysql_item, backup["username"], backup["password"]
    end

    private

    # helper
    def node_server
      @node["percona"]["server"]
    end

    def data_bag_secret_file
      if !secret_file.empty? && ::File.exist?(secret_file)
        secret_file
      elsif !Chef::Config[:encrypted_data_bag_secret].empty?
        Chef::Config[:encrypted_data_bag_secret]
      end
    end

    def secret
      return unless data_bag_secret_file

      Chef::EncryptedDataBagItem.load_secret(data_bag_secret_file)
    end
  end
end
