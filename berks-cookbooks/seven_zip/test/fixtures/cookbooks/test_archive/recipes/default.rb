# This recipe is for testing the seven_zip archive provider
include_recipe 'seven_zip'

seven_zip_archive 'test_archive' do
  path      'C:\seven_zip_source'
  source    node['test_archive']['source']
  overwrite node['test_archive']['overwrite']
  checksum  node['test_archive']['checksum']
  timeout   30
end

seven_zip_archive 'extract_with_spaces' do
  path      'C:\Program Files\seven_zip_source'
  source    node['test_archive']['source']
  overwrite node['test_archive']['overwrite']
  checksum  node['test_archive']['checksum']
end
