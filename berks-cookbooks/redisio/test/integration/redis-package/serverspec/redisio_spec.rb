require 'spec_helper'

describe 'Redis' do
  it_behaves_like 'redis on port', 6379
end
