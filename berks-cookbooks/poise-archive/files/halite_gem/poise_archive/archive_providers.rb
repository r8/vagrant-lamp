#
# Copyright 2016-2017, Noah Kantrowitz
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

require 'chef/platform/provider_priority_map'

require 'poise_archive/archive_providers/gnu_tar'
require 'poise_archive/archive_providers/seven_zip'
require 'poise_archive/archive_providers/tar'
require 'poise_archive/archive_providers/zip'


module PoiseArchive
  # Providers for the poise_archive resource.
  #
  # @since 1.0.0
  module ArchiveProviders
    # Set up priority maps
    Chef::Platform::ProviderPriorityMap.instance.priority(:poise_archive, [
      PoiseArchive::ArchiveProviders::Zip,
      PoiseArchive::ArchiveProviders::GnuTar,
      PoiseArchive::ArchiveProviders::SevenZip,
      PoiseArchive::ArchiveProviders::Tar,
    ])
  end
end
