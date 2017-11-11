#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: windows
# Resource:: font
#
# Copyright:: 2014-2017, Schuberg Philis BV.
# Copyright:: 2017, Chef Software, Inc.
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

property :font_name, String, name_property: true
property :source, String, required: false, coerce: proc { |x| x.tr('\\', '/').gsub('//', '/') }

include Windows::Helper

action :install do
  if font_exists?
    Chef::Log.debug("Not installing font: #{new_resource.font_name} as font already installed.")
  else
    retrieve_cookbook_font
    install_font
    del_cookbook_font
  end
end

action_class do
  def retrieve_cookbook_font
    font_file = new_resource.font_name
    if new_resource.source
      remote_file font_file do
        action :nothing
        source source_uri
        path win_friendly_path(::File.join(ENV['TEMP'], font_file))
      end.run_action(:create)
    else
      cookbook_file font_file do
        action    :nothing
        cookbook  cookbook_name.to_s unless cookbook_name.nil?
        path      win_friendly_path(::File.join(ENV['TEMP'], font_file))
      end.run_action(:create)
    end
  end

  def del_cookbook_font
    file ::File.join(ENV['TEMP'], new_resource.font_name) do
      action :delete
    end
  end

  def install_font
    require 'win32ole' if RUBY_PLATFORM =~ /mswin|mingw32|windows/
    fonts_dir = WIN32OLE.new('WScript.Shell').SpecialFolders('Fonts')
    folder = WIN32OLE.new('Shell.Application').Namespace(fonts_dir)
    converge_by("install font #{new_resource.font_name} to #{fonts_dir}") do
      folder.CopyHere(win_friendly_path(::File.join(ENV['TEMP'], new_resource.font_name)))
    end
  end

  # Check to see if the font is installed in the fonts dir
  #
  # === Returns
  # <true>:: If the font is installed
  # <false>:: If the font is not instaled
  def font_exists?
    require 'win32ole' if RUBY_PLATFORM =~ /mswin|mingw32|windows/
    fonts_dir = WIN32OLE.new('WScript.Shell').SpecialFolders('Fonts')
    Chef::Log.debug("Seeing if the font at #{win_friendly_path(::File.join(fonts_dir, new_resource.font_name))} exists")
    ::File.exist?(win_friendly_path(::File.join(fonts_dir, new_resource.font_name)))
  end

  # is the parsed schema one supported by remote file.
  # URI will parse C:/foo as schema 'c' so we need to detect that
  def remote_file_schema?(schema)
    return true if %w(http https ftp).include?(schema)
  end

  # return new_resource.source if we have a proper URI specified
  # if it's a local file listed as a source return it in file:// format
  def source_uri
    begin
      require 'uri'
      if remote_file_schema?(URI.parse(new_resource.source).scheme)
        Chef::Log.debug('source property starts with ftp/http. Using source property unmodified')
        return new_resource.source
      end
    rescue URI::InvalidURIError
      Chef::Log.warn("source property of #{new_resource.source} could not be processed as a URI. Check the format you provided.")
    end
    Chef::Log.debug('source property does not start with ftp/http. Prepending with file:// as it appears to be a local file.')
    "file://#{new_resource.source}"
  end
end
