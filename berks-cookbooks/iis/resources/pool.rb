#
# Author:: Kendrick Martin (kendrick.martin@webtrends.com>)
# Contributor:: David Dvorak (david.dvorak@webtrends.com)
# Cookbook Name:: iis
# Resource:: pool
#
# Copyright:: 2011, Webtrends Inc.
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

actions :add, :config, :delete, :start, :stop, :restart, :recycle
default_action :add

# root
attribute :pool_name, kind_of: String, name_attribute: true
attribute :no_managed_code, kind_of: [TrueClass, FalseClass], default: false
attribute :pipeline_mode, kind_of: Symbol, equal_to: [:Integrated, :Classic]
attribute :runtime_version, kind_of: String

# add items
attribute :start_mode, kind_of: Symbol, equal_to: [:AlwaysRunning, :OnDemand], default: :OnDemand
attribute :auto_start, kind_of: [TrueClass, FalseClass], default: true
attribute :queue_length, kind_of: Integer, default: 1000
attribute :thirty_two_bit, kind_of: [TrueClass, FalseClass], default: false

# processModel items
attribute :max_proc, kind_of: Integer
attribute :load_user_profile, kind_of: [TrueClass, FalseClass], default: false
attribute :pool_identity, kind_of: Symbol, equal_to: [:SpecificUser, :NetworkService, :LocalService, :LocalSystem, :ApplicationPoolIdentity], default: :ApplicationPoolIdentity
attribute :pool_username, kind_of: String
attribute :pool_password, kind_of: String
attribute :logon_type, kind_of: Symbol, equal_to: [:LogonBatch, :LogonService], default: :LogonBatch
attribute :manual_group_membership, kind_of: [TrueClass, FalseClass], default: false
attribute :idle_timeout, kind_of: String, default: '00:20:00'
attribute :shutdown_time_limit, kind_of: String, default: '00:01:30'
attribute :startup_time_limit, kind_of: String, default: '00:01:30'
attribute :pinging_enabled, kind_of: [TrueClass, FalseClass], default: true
attribute :ping_interval, kind_of: String, default: '00:00:30'
attribute :ping_response_time, kind_of: String, default: '00:01:30'

# recycling items
attribute :disallow_rotation_on_config_change, kind_of: [TrueClass, FalseClass], default: false
attribute :disallow_overlapping_rotation, kind_of: [TrueClass, FalseClass], default: false
attribute :recycle_after_time, kind_of: String
attribute :recycle_at_time, kind_of: String
attribute :private_mem, kind_of: Integer

# failure items
attribute :load_balancer_capabilities, kind_of: Symbol, equal_to: [:HttpLevel, :TcpLevel], default: :HttpLevel
attribute :orphan_worker_process, kind_of: [TrueClass, FalseClass], default: false
attribute :orphan_action_exe, kind_of: String
attribute :orphan_action_params, kind_of: String
attribute :rapid_fail_protection, kind_of: [TrueClass, FalseClass], default: true
attribute :rapid_fail_protection_interval, kind_of: String, default: '00:05:00'
attribute :rapid_fail_protection_max_crashes, kind_of: Integer, default: 5
attribute :auto_shutdown_exe, kind_of: String
attribute :auto_shutdown_params, kind_of: String

# cpu items
attribute :cpu_action, kind_of: Symbol, equal_to: [:NoAction, :KillW3wp, :Throttle, :ThrottleUnderLoad], default: :NoAction
attribute :cpu_limit, kind_of: Integer, default: 0
attribute :cpu_reset_interval, kind_of: String, default: '00:05:00'
attribute :cpu_smp_affinitized, kind_of: [TrueClass, FalseClass], default: false
attribute :smp_processor_affinity_mask, kind_of: Bignum, default: 4_294_967_295
attribute :smp_processor_affinity_mask_2, kind_of: Bignum, default: 4_294_967_295

attr_accessor :exists, :running
