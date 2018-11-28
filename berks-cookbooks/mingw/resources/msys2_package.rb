#
# Cookbook:: mingw
# Resource:: msys2_package
#
# Copyright:: 2016, Chef Software, Inc.
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

# Installs msys2 base system and installs/upgrades packages within in.
#
# Where's the version flag?  Where's idempotence you say?  Well f*** you
# for trying to version your product.  This is arch.  They live on the edge.
# You never get anything but the latest version.  And if that's broken...
# well that's your problem isn't it?  And they don't believe in preserving
# older versions.  Good luck!

property :package, String, name_property: true
property :root, String, required: true

resource_name :msys2_package

action_class do
  #
  # Runs a command through a bash login shell made by our shim .bat file.
  # The bash.bat file defaults %HOME% to #{root}/home/%USERNAME% and requests
  # that the command be run in the current working directory.
  #
  def msys2_exec(comment, cmd)
    f_root = win_friendly_path(root)
    execute comment do
      command ".\\bin\\bash.bat -c '#{cmd}'"
      cwd f_root
      live_stream true
      environment('MSYSTEM' => 'MSYS')
    end
  end

  def msys2_init
    cache_dir = ::File.join(root, '.cache')
    f_cache_dir = win_friendly_path(cache_dir)
    base_url = node['msys2']['url']
    base_checksum = node['msys2']['checksum']

    unless ::File.exist?(::File.join(root, 'msys2.exe'))
      seven_zip_archive "cache msys2 base to #{f_cache_dir}" do
        source base_url
        path f_cache_dir
        checksum base_checksum
        overwrite true
      end

      seven_zip_archive "extract msys2 base archive to #{f_cache_dir}" do
        source "#{f_cache_dir}\\#{tar_name(base_url)}"
        path f_cache_dir
        overwrite true
      end

      ruby_block 'copy msys2 base files to root' do
        block do
          # Oh my god msys2 and pacman are picky as hell when it comes to
          # updating core files. They use the mtime on certain files to
          # determine if they need to updated or not and simply skip various
          # steps otherwise.
          ::FileUtils.cp_r(::Dir.glob("#{cache_dir}/msys64/*"), root, preserve: true)
        end
      end
    end

    pacman_key_dir = ::File.join(root, 'etc/pacman.d/gnupg')
    bin_dir = ::File.join(root, 'bin')

    directory win_friendly_path(bin_dir)

    cookbook_file win_friendly_path("#{bin_dir}/bash.bat") do
      source 'bash.bat'
      cookbook 'mingw'
    end

    cookbook_file win_friendly_path(::File.join(root, 'custom-upgrade.sh')) do
      source 'custom-upgrade.sh'
      cookbook 'mingw'
    end

    cookbook_file win_friendly_path(::File.join(root, 'etc/profile.d/custom_prefix.sh')) do
      source 'custom_prefix.sh'
      cookbook 'mingw'
    end

    # $HOME is using files from /etc/skel.  The home-directory creation step
    # will automatically be performed if other users log in - so if you wish
    # to globally modify user first time setup, edit /etc/skel or add
    # "post-setup" steps to /etc/post-install/
    # The first-time init shell must be restarted and cannot be reused.
    msys2_exec('msys2 first time init', 'exit') unless ::File.exist?(pacman_key_dir)

    # Update pacman and msys base packages.
    if ::File.exist?(::File.join(root, 'usr/bin/update-core')) || !::File.exist?(::File.join(root, 'custom-upgrade.sh'))
      msys2_exec('upgrade msys2 core', '/custom-upgrade.sh')
      msys2_exec('upgrade msys2 core: part 2', 'pacman -Suu --noconfirm')
      # Now we can actually upgrade everything ever.
      msys2_exec('upgrade entire msys2 system: 1', 'pacman -Syuu --noconfirm')
      # Might need to do it once more to pick up a few stragglers.
      msys2_exec('upgrade entire msys2 system: 2', 'pacman -Syuu --noconfirm')
    end
  end

  def msys2_do_action(comment, action_cmd)
    msys2_init
    msys2_exec(comment, action_cmd)
  end
end

action :install do
  msys2_do_action("installing #{package}", "pacman -S --needed --noconfirm #{package}")
end

# Package name is ignored.  This is arch.  Why would you ever upgrade a single
# package and its deps?  That'll just break everything else that ever depended
# on a different version of that dep.  Because arch is wonderful like that.
# So you only get the choice to move everything to latest or not...  it's the
# most agile development possible!
action :upgrade do
  msys2_do_action("upgrading #{package}", "pacman -Syu --noconfirm #{package}")
end

action :remove do
  msys2_do_action("removing #{package}", "pacman -R --noconfirm #{package}")
end
