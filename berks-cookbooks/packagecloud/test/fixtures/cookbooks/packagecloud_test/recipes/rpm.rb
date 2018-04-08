include_recipe 'packagecloud_test::distro_deps'

packagecloud_repo 'computology_public_rpm' do
  repository 'computology/packagecloud-cookbook-test-public'
  type 'rpm'
end

package 'jake'

packagecloud_repo 'computology/packagecloud-cookbook-test-private' do
  type 'rpm'
  master_token '762748f7ae0bfdb086dd539575bdc8cffdca78c6a9af0db9'
end

package 'man'
package 'jake-docs'

packagecloud_repo 'computology/packagecloud-test-packages' do
  type 'rpm'
  force_os 'rhel'
  force_dist '6.7'
end

package 'packagecloud-test'
