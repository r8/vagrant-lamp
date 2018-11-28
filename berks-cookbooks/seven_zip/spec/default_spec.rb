describe 'seven_zip::default' do
  context 'with defaults' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(step_into: 'seven_zip_tool').converge(described_recipe)
    end
    it 'installs seven_zip package' do
      expect(chef_run).to install_windows_package '7-Zip 18.05 (x64 edition)'
    end
    it 'updates the path to include seven_zip' do
      expect(chef_run).to_not add_windows_path('seven_zip').with(path: 'C:\\\\7-zip')
    end
  end
  context 'with syspath' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(step_into: 'seven_zip_tool') do |node|
        node.override['seven_zip']['syspath'] = true
        node.override['seven_zip']['home'] = 'C:\\\\7-zip'
      end.converge(described_recipe)
    end
    it 'installs seven_zip package' do
      expect(chef_run).to install_windows_package '7-Zip 18.05 (x64 edition)'
    end
    it 'updates the path to include seven_zip' do
      expect(chef_run).to add_windows_path('seven_zip').with(path: 'C:\\\\7-zip')
    end
  end
end
