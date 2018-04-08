if os[:family] == 'ubuntu'
  sources_content = "deb https://packagecloud.io/computology/packagecloud-test-packages/debian wheezy main\ndeb-src https://packagecloud.io/computology/packagecloud-test-packages/debian wheezy main\n"

  describe file('/etc/apt/sources.list.d/computology_packagecloud-test-packages.list') do
    it { should exist }
    its(:content) { should eq sources_content }
  end
end
