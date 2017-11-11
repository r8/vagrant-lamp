require 'spec_helper'

describe 'Redis-Sentinel' do
  it_behaves_like 'sentinel on port', 26379
end
