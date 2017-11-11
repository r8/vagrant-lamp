shared_examples_for 'sentinel on port' do |redis_port, redis_cluster_name, _args|
  it 'enables the redis-sentinel service' do
    redis_cluster_name ||= 'mycluster'
    name = if (os[:family] == 'redhat' && os[:release][0] == '7') ||
              (os[:family] == 'ubuntu' && os[:release].to_f >= 16.04) ||
              (os[:family] == 'debian' && os[:release].to_f >= 8.0) ||
              os[:family] == 'fedora'
             "redis-sentinel@#{redis_cluster_name}"
           else
             "redis_sentinel_#{redis_cluster_name}"
           end
    expect(service name).to be_enabled
    expect(service name).to be_running, if: os[:family] != 'fedora'
  end

  describe command("ps aux | grep -v grep | grep 'redis-server' | grep '*:#{redis_port}'"), if: os[:family] == 'fedora' do
    its(:exit_status) { should eq(0) }
  end

  it "is listening on port #{redis_port}" do
    expect(port redis_port).to be_listening
  end
end
