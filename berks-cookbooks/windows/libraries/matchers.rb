if defined?(ChefSpec)

  ChefSpec.define_matcher :windows_auto_run
  ChefSpec.define_matcher :windows_certificate
  ChefSpec.define_matcher :windows_certificate_binding
  ChefSpec.define_matcher :windows_feature
  ChefSpec.define_matcher :windows_feature_dism
  ChefSpec.define_matcher :windows_feature_servermanagercmd
  ChefSpec.define_matcher :windows_feature_powershell
  ChefSpec.define_matcher :windows_font
  ChefSpec.define_matcher :windows_http_acl
  ChefSpec.define_matcher :windows_pagefile
  ChefSpec.define_matcher :windows_path
  ChefSpec.define_matcher :windows_printer
  ChefSpec.define_matcher :windows_printer_port
  ChefSpec.define_matcher :windows_share
  ChefSpec.define_matcher :windows_shortcut
  ChefSpec.define_matcher :windows_task
  ChefSpec.define_matcher :windows_zipfile

  #
  # Assert that a +windows_certificate+ resource exists in the Chef run with the
  # action +:create+. Given a Chef Recipe that creates 'c:\test\mycert.pfx' as a
  # +windows_certificate+:
  #
  #     windows_certificate 'c:\test\mycert.pfx' do
  #       action :create
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_certificate+ resource with ChefSpec.
  #
  # @example Assert that a +windows_certificate+ was created
  #   expect(chef_run).to create_windows_certificate('c:\test\mycert.pfx')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def create_windows_certificate(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_certificate, :create, resource_name)
  end

  #
  # Assert that a +windows_certificate+ resource exists in the Chef run with the
  # action +:delete+. Given a Chef Recipe that deletes "me.acme.com" as a
  # +windows_certificate+:
  #
  #     windows_certificate 'me.acme.com' do
  #       action :delete
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_certificate+ resource with ChefSpec.
  #
  # @example Assert that a +windows_certificate+ was _not_ deleted
  #   expect(chef_run).to_not delete_windows_certificate('me.acme.com')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def delete_windows_certificate(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_certificate, :delete, resource_name)
  end

  #
  # Assert that a +windows_certificate+ resource exists in the Chef run with the
  # action +:acl_add+. Given a Chef Recipe that adds a private key acl to "me.acme.com" as a
  # +windows_certificate+:
  #
  #     windows_certificate 'me.acme.com' do
  #       private_key_acl ['acme\fred', 'pc\jane']
  #       action :acl_add
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_certificate+ resource with ChefSpec.
  #
  # @example Assert that a +windows_certificate+ was _not_ removed
  #   expect(chef_run).to add_acl_to_windows_certificate('me.acme.com').with(private_key_acl: ['acme\fred', 'pc\jane'])
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def add_acl_to_windows_certificate(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_certificate, :acl_add, resource_name)
  end

  #
  # Assert that a +windows_feature+ resource exists in the Chef run with the
  # action +:install+. Given a Chef Recipe that installs "NetFX3" as a
  # +windows_feature+:
  #
  #     windows_feature 'NetFX3' do
  #       action :install
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_feature+ resource with ChefSpec.
  #
  # @example Assert that a +windows_feature+ was installed
  #   expect(chef_run).to install_windows_feature('NetFX3')
  #
  # @example Assert that a +windows_feature+ was _not_ installed
  #   expect(chef_run).to_not install_windows_feature('NetFX3')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def install_windows_feature(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature, :install, resource_name)
  end

  def install_windows_feature_servermanagercmd(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature_servermanagercmd, :install, resource_name)
  end

  def install_windows_feature_dism(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature_dism, :install, resource_name)
  end

  def install_windows_feature_powershell(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature_powershell, :install, resource_name)
  end

  #
  # Assert that a +windows_feature+ resource exists in the Chef run with the
  # action +:remove+. Given a Chef Recipe that removes "NetFX3" as a
  # +windows_feature+:
  #
  #     windows_feature 'NetFX3' do
  #       action :remove
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_feature+ resource with ChefSpec.
  #
  # @example Assert that a +windows_feature+ was removed
  #   expect(chef_run).to remove_windows_feature('NetFX3')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def remove_windows_feature(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature, :remove, resource_name)
  end

  def remove_windows_feature_servermanagercmd(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature_servermanagercmd, :remove, resource_name)
  end

  def remove_windows_feature_dism(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature_dism, :remove, resource_name)
  end

  def remove_windows_feature_powershell(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature_powershell, :remove, resource_name)
  end

  #
  # Assert that a +windows_feature+ resource exists in the Chef run with the
  # action +:delete+. Given a Chef Recipe that deletes "NetFX3" as a
  # +windows_feature+:
  #
  #     windows_feature 'NetFX3' do
  #       action :delete
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_feature+ resource with ChefSpec.
  #
  # @example Assert that a +windows_feature+ was deleted
  #   expect(chef_run).to delete_windows_feature('NetFX3')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def delete_windows_feature(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature, :delete, resource_name)
  end

  def delete_windows_feature_dism(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature_dism, :delete, resource_name)
  end

  def delete_windows_feature_powershell(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_feature_powershell, :delete, resource_name)
  end

  #
  # Assert that a +windows_task+ resource exists in the Chef run with the
  # action +:create+. Given a Chef Recipe that creates "mytask" as a
  # +windows_task+:
  #
  #     windows_task 'mytask' do
  #       command 'mybatch.bat'
  #       action :create
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_task+ resource with ChefSpec.
  #
  # @example Assert that a +windows_task+ was created
  #   expect(chef_run).to create_windows_task('mytask')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def create_windows_task(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_task, :create, resource_name)
  end

  #
  # Assert that a +windows_task+ resource exists in the Chef run with the
  # action +:disable+. Given a Chef Recipe that creates "mytask" as a
  # +windows_task+:
  #
  #     windows_task 'mytask' do
  #       action :disable
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_task+ resource with ChefSpec.
  #
  # @example Assert that a +windows_task+ was disabled
  #   expect(chef_run).to disable_windows_task('mytask')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def disable_windows_task(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_task, :disable, resource_name)
  end

  #
  # Assert that a +windows_task+ resource exists in the Chef run with the
  # action +:enable+. Given a Chef Recipe that creates "mytask" as a
  # +windows_task+:
  #
  #     windows_task 'mytask' do
  #       action :enable
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_task+ resource with ChefSpec.
  #
  # @example Assert that a +windows_task+ was enabled
  #   expect(chef_run).to enable_windows_task('mytask')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def enable_windows_task(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_task, :enable, resource_name)
  end

  #
  # Assert that a +windows_task+ resource exists in the Chef run with the
  # action +:delete+. Given a Chef Recipe that deletes "mytask" as a
  # +windows_task+:
  #
  #     windows_task 'mytask' do
  #       action :delete
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_task+ resource with ChefSpec.
  #
  # @example Assert that a +windows_task+ was deleted
  #   expect(chef_run).to delete_windows_task('mytask')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def delete_windows_task(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_task, :delete, resource_name)
  end

  #
  # Assert that a +windows_task+ resource exists in the Chef run with the
  # action +:run+. Given a Chef Recipe that runs "mytask" as a
  # +windows_task+:
  #
  #     windows_task 'mytask' do
  #       action :run
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_task+ resource with ChefSpec.
  #
  # @example Assert that a +windows_task+ was run
  #   expect(chef_run).to run_windows_task('mytask')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def run_windows_task(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_task, :run, resource_name)
  end

  #
  # Assert that a +windows_task+ resource exists in the Chef run with the
  # action +:change+. Given a Chef Recipe that changes "mytask" as a
  # +windows_task+:
  #
  #     windows_task 'mytask' do
  #       action :change
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_task+ resource with ChefSpec.
  #
  # @example Assert that a +windows_task+ was changed
  #   expect(chef_run).to change_windows_task('mytask')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def change_windows_task(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_task, :change, resource_name)
  end

  #
  # Assert that a +windows_path+ resource exists in the Chef run with the
  # action +:add+. Given a Chef Recipe that adds "C:\7-Zip" to the Windows
  # PATH env var
  #
  #     windows_path 'C:\7-Zip' do
  #       action :add
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_path+ resource with ChefSpec.
  #
  # @example Assert that a +windows_path+ was added
  #   expect(chef_run).to add_windows_path('C:\7-Zip')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def add_windows_path(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_path, :add, resource_name)
  end

  #
  # Assert that a +windows_path+ resource exists in the Chef run with the
  # action +:remove+. Given a Chef Recipe that removes "C:\7-Zip" from the
  # Windows PATH env var
  #
  #     windows_path 'C:\7-Zip' do
  #       action :remove
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_path+ resource with ChefSpec.
  #
  # @example Assert that a +windows_path+ was removed
  #   expect(chef_run).to remove_windows_path('C:\7-Zip')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def remove_windows_path(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_path, :remove, resource_name)
  end

  #
  # Assert that a +windows_pagefile+ resource exists in the Chef run with the
  # action +:set+. Given a Chef Recipe that sets a pagefile
  #
  #     windows_pagefile "pagefile" do
  #       system_managed true
  #       initial_size 1024
  #       maximum_size 4096
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_pagefile+ resource with ChefSpec.
  #
  # @example Assert that a +windows_pagefile+ was set
  #   expect(chef_run).to set_windows_pagefile('pagefile').with(
  #     initial_size: 1024)
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def set_windows_pagefile(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_pagefile, :set, resource_name)
  end

  #
  # Assert that a +windows_zipfile+ resource exists in the Chef run with the
  # action +:unzip+. Given a Chef Recipe that extracts "SysinternalsSuite.zip"
  # to c:/bin
  #
  #     windows_zipfile "c:/bin" do
  #       source "http://download.sysinternals.com/Files/SysinternalsSuite.zip"
  #       action :unzip
  #       not_if {::File.exists?("c:/bin/PsExec.exe")}
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_zipfile+ resource with ChefSpec.
  #
  # @example Assert that a +windows_zipfile+ was unzipped
  #   expect(chef_run).to unzip_windows_zipfile_to('c:/bin')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def unzip_windows_zipfile_to(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_zipfile, :unzip, resource_name)
  end

  #
  # Assert that a +windows_zipfile+ resource exists in the Chef run with the
  # action +:zip+. Given a Chef Recipe that zips "c:/src"
  # to c:/code.zip
  #
  #     windows_zipfile "c:/code.zip" do
  #       source "c:/src"
  #       action :zip
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_zipfile+ resource with ChefSpec.
  #
  # @example Assert that a +windows_zipfile+ was zipped
  #   expect(chef_run).to zip_windows_zipfile_to('c:/code.zip')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def zip_windows_zipfile_to(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_zipfile, :zip, resource_name)
  end

  #
  # Assert that a +windows_share+ resource exists in the Chef run with the
  # action +:create+. Given a Chef Recipe that shares "c:/src"
  # as Src
  #
  #     windows_share "Src" do
  #       path "c:/src"
  #       action :create
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_share+ resource with ChefSpec.
  #
  # @example Assert that a +windows_share+ was created
  #   expect(chef_run).to create_windows_share('Src')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def create_windows_share(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_share, :create, resource_name)
  end

  #
  # Assert that a +windows_share+ resource exists in the Chef run with the
  # action +:delete+. Given a Chef Recipe that deletes share "c:/src"
  #
  #     windows_share "Src" do
  #       action :delete
  #     end
  #
  # The Examples section demonstrates the different ways to test a
  # +windows_share+ resource with ChefSpec.
  #
  # @example Assert that a +windows_share+ was created
  #   expect(chef_run).to delete_windows_share('Src')
  #
  #
  # @param [String, Regex] resource_name
  #   the name of the resource to match
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def delete_windows_share(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_share, :delete, resource_name)
  end

  # All the other less commonly used LWRPs
  def create_windows_shortcut(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_shortcut, :create, resource_name)
  end

  def create_windows_auto_run(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_auto_run, :create, resource_name)
  end

  def remove_windows_auto_run(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_auto_run, :remove, resource_name)
  end

  def create_windows_printer(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_printer, :create, resource_name)
  end

  def delete_windows_printer(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_printer, :delete, resource_name)
  end

  def create_windows_printer_port(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_printer_port, :create, resource_name)
  end

  def delete_windows_printer_port(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_printer_port, :delete, resource_name)
  end

  def install_windows_font(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_font, :install, resource_name)
  end

  def create_windows_certificate_binding(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_certificate_binding, :create, resource_name)
  end

  def delete_windows_certificate_binding(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_certificate_binding, :delete, resource_name)
  end

  def create_windows_http_acl(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_http_acl, :create, resource_name)
  end

  def delete_windows_http_acl(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:windows_http_acl, :delete, resource_name)
  end
end
