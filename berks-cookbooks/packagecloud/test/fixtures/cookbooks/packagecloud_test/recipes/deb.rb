include_recipe 'packagecloud_test::distro_deps'

packagecloud_repo 'computology_public_deb' do
  repository 'computology/packagecloud-cookbook-test-public'
  type 'deb'
end

package 'jake'

packagecloud_repo 'computology_private' do
  repository 'computology/packagecloud-cookbook-test-private'
  type 'deb'
  master_token '762748f7ae0bfdb086dd539575bdc8cffdca78c6a9af0db9'
end

package 'jake-doc'

execute 'install_jake_source' do
  command 'apt-get source jake'
end

packagecloud_repo 'computology/packagecloud-test-packages' do
  type 'deb'
  force_os 'debian'
  force_dist 'wheezy'
end
