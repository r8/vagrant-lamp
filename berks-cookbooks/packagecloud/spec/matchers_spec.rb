require 'chefspec'
require 'chefspec/berkshelf'

describe 'packagecloud_test::deb' do
  let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04').converge(described_recipe) }

  it 'should create packagecloud_repo' do
    expect(chef_run).to create_packagecloud_repo('computology_public_deb')
  end

  it 'should create packagecloud_repo with type of deb' do
    expect(chef_run).to create_packagecloud_repo('computology_public_deb') \
      .with_type('deb')
  end
end
