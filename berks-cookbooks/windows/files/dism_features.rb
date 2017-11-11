#
# Author:: Wade Peacock <wade.peacock@visioncritical.com>
# License:: Apache License, Version 2.0
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
## See the License for the specific language governing permissions and
# limitations under the License.
#

Ohai.plugin(:DismFeatures) do
  provides 'dism_features'
  collect_data(:windows) do
    dism_features Mash.new
    # This is for 32-bit ruby/chef client on 64-bit Windows
    # This emulates the locate_sysnative_cmd helper as it is not available
    cmd = 'dism.exe'
    dism = if ::File.exist?("#{ENV['WINDIR']}\\sysnative\\#{cmd}")
             "#{ENV['WINDIR']}\\sysnative\\#{cmd}"
           elsif ::File.exist?("#{ENV['WINDIR']}\\system32\\#{cmd}")
             "#{ENV['WINDIR']}\\system32\\#{cmd}"
           else
             cmd
           end
    # Grab raw feature information from dism command line
    raw_list_of_features = shell_out("#{dism} /Get-Features /Online /Format:Table /English").stdout
    # Split stdout into an array by windows line ending
    features_list = raw_list_of_features.split("\r\n")
    features_list.each do |feature_details_raw|
      # Skip lines that do not match Enable / Disable
      next unless feature_details_raw =~ /(En|Dis)able/
      # Strip trailing whitespace characters then split on n number of spaces + | +  n number of spaces
      feature_details = feature_details_raw.strip.split(/\s+[|]\s+/)
      # Add to Mash
      dism_features[feature_details.first] = feature_details.last
    end
  end
end
