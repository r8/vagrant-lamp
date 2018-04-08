class Chef
  class Provider
    class GitClient
      class Source < Chef::Provider::GitClient
        action :install do
          raise "#{node['platform']} is not supported by the git_client source resource" unless platform_family?('rhel', 'suse', 'fedora', 'debian', 'amazon')

          build_essential 'install compilation tools for git'

          # move this to attributes.
          case node['platform_family']
          when 'rhel', 'fedora', 'amazon'
            pkgs = %w(tar expat-devel gettext-devel libcurl-devel openssl-devel perl-ExtUtils-MakeMaker zlib-devel)
            pkgs += %w( pcre-devel ) if new_resource.source_use_pcre
          when 'debian'
            pkgs = %w(libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev)
            pkgs += %w( libpcre3-dev ) if new_resource.source_use_pcre
          when 'suse'
            pkgs = %w(tar libcurl-devel libexpat-devel gettext-tools zlib-devel libopenssl-devel)
            pkgs += %w( libpcre2-devel ) if new_resource.source_use_pcre
          end

          package pkgs

          # reduce line-noise-eyness
          remote_file "#{Chef::Config['file_cache_path']}/git-#{new_resource.source_version}.tar.gz" do
            source parsed_source_url # helpers.rb
            checksum parsed_source_checksum # helpers.rb
            mode '0644'
            not_if "test -f #{Chef::Config['file_cache_path']}/git-#{new_resource.source_version}.tar.gz"
          end

          # reduce line-noise-eyness
          execute "Extracting and Building Git #{new_resource.source_version} from Source" do
            cwd Chef::Config['file_cache_path']
            additional_make_params = ''
            additional_make_params += 'USE_LIBPCRE=1' if new_resource.source_use_pcre
            command <<-COMMAND
    (mkdir git-#{new_resource.source_version} && tar -zxf git-#{new_resource.source_version}.tar.gz -C git-#{new_resource.source_version} --strip-components 1)
    (cd git-#{new_resource.source_version} && make prefix=#{new_resource.source_prefix} #{additional_make_params} install)
  COMMAND
            not_if "git --version | grep #{new_resource.source_version}"
            not_if "#{new_resource.source_prefix}/bin/git --version | grep #{new_resource.source_version}"
          end
        end

        action :delete do
        end
      end
    end
  end
end
