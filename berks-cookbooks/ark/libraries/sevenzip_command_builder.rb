module Ark
  class SevenZipCommandBuilder
    def unpack
      sevenzip_command
    end

    def dump
      sevenzip_command_builder(resource.path, 'e')
    end

    def cherry_pick
      "#{sevenzip_command_builder(resource.path, 'x')} -r #{resource.creates}"
    end

    def initialize(resource)
      @resource = resource
    end

    private

    attr_reader :resource

    def node
      resource.run_context.node
    end

    def sevenzip_command
      if resource.strip_components <= 0
        return sevenzip_command_builder(resource.path, 'x')
      end

      tmpdir = make_temp_directory.tr('/', '\\')
      cmd = sevenzip_command_builder(tmpdir, 'x')

      cmd += ' && '
      currdir = tmpdir

      1.upto(resource.strip_components).each do |count|
        cmd += "for /f %#{count} in ('dir /ad /b \"#{currdir}\"') do "
        currdir += "\\%#{count}"
      end

      cmd += "(\"#{ENV.fetch('SystemRoot')}\\System32\\robocopy\" \"#{currdir}\" \"#{resource.path}\" /s /e) ^& IF %ERRORLEVEL% LEQ 3 cmd /c exit 0"
    end

    def sevenzip_binary
      @tar_binary ||= "\"#{(node['ark']['sevenzip_binary'] || sevenzip_path_from_registry)}\""
    end

    def sevenzip_path_from_registry
      begin
        basepath = ::Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe').read_s('Path')

      # users like pretty errors
      rescue ::Win32::Registry::Error
        raise 'Failed to find the path of 7zip binary by searching checking HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe\Path. Make sure to install 7zip before using this resource. If 7zip is installed and you still receive this message you can also specify the 7zip binary path by setting node["ark"]["sevenzip_binary"]'
      end
      "#{basepath}7z.exe"
    end

    def sevenzip_command_builder(dir, command)
      "#{sevenzip_binary} #{command} \"#{resource.release_file}\"#{extension_is_tar} -o\"#{dir}\" -uy"
    end

    def extension_is_tar
      if resource.extension =~ /tar.gz|tgz|tar.bz2|tbz|tar.xz|txz/
        " -so | #{sevenzip_binary} x -aoa -si -ttar"
      else
        ' -aoa' # force overwrite, Fixes #164
      end
    end

    def make_temp_directory
      require 'tmpdir'
      Dir.mktmpdir
    end
  end
end
