#
# Cookbook:: windows
# Library:: version_helper
# Author:: Baptiste Courtois (<b.courtois@criteo.com>)
#
# Copyright:: 2015-2017, Criteo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Windows
  # Module based on windows ohai kernel.cs_info providing version helpers
  module VersionHelper
    # Module referencing CORE SKU contants from product type
    # see. https://msdn.microsoft.com/windows/desktop/ms724358#PRODUCT_DATACENTER_SERVER_CORE
    # n.b. Prefix - PRODUCT_ - and suffix - _CORE- have been removed
    module CoreSKU
      # Server Datacenter Core
      DATACENTER_SERVER   = 0x0C unless constants.include?(:DATACENTER_SERVER)
      # Server Datacenter without Hyper-V Core
      DATACENTER_SERVER_V = 0x27 unless constants.include?(:DATACENTER_SERVER_V)
      # Server Enterprise Core
      ENTERPRISE_SERVER   = 0x0E unless constants.include?(:ENTERPRISE_SERVER)
      # Server Enterprise without Hyper-V Core
      ENTERPRISE_SERVER_V = 0x29 unless constants.include?(:ENTERPRISE_SERVER_V)
      # Server Standard Core
      STANDARD_SERVER     = 0x0D unless constants.include?(:STANDARD_SERVER)
      # Server Standard without Hyper-V Core
      STANDARD_SERVER_V   = 0x28 unless constants.include?(:STANDARD_SERVER_V)
    end

    # Module referencing product type contants
    # see. https://msdn.microsoft.com/windows/desktop/ms724833#VER_NT_SERVER
    # n.b. Prefix - VER_NT_ - has been removed
    module ProductType
      WORKSTATION         = 0x1 unless constants.include?(:WORKSTATION)
      DOMAIN_CONTROLLER   = 0x2 unless constants.include?(:DOMAIN_CONTROLLER)
      SERVER              = 0x3 unless constants.include?(:SERVER)
    end

    # Determines whether current node is running a windows Core version
    def self.core_version?(node)
      validate_platform node

      CoreSKU.constants.any? { |c| CoreSKU.const_get(c) == node['kernel']['os_info']['operating_system_sku'] }
    end

    # Determines whether current node is a workstation version
    def self.workstation_version?(node)
      validate_platform node
      node['kernel']['os_info']['product_type'] == ProductType::WORKSTATION
    end

    # Determines whether current node is a server version
    def self.server_version?(node)
      !workstation_version?(node)
    end

    # Determines NT version of the current node
    def self.nt_version(node)
      validate_platform node

      node['platform_version'].to_f
    end

    def self.validate_platform(node)
      raise 'Windows helper are only supported on windows platform!' if node['platform'] != 'windows'
    end
  end
end
