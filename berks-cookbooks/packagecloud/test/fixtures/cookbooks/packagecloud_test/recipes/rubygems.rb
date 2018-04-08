include_recipe 'packagecloud_test::distro_deps'

packagecloud_repo 'computology/packagecloud-cookbook-test-public' do
  type 'gem'
end

if platform?('centos') && node['platform_version'].to_i == 5
  execute 'gem install' do
    command 'gem install jakedotrb --bindir /usr/local/bin'
  end
else
  gem_package 'jakedotrb' do
    options '--bindir /usr/local/bin'
    version '0.0.1'
    source 'https://packagecloud.io/computology/packagecloud-cookbook-test-public/'
  end
end
