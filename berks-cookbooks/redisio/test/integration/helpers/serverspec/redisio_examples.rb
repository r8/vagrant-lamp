shared_examples_for 'redis on port' do |redis_port, _args|
  it 'enables the redis service' do
    service_name = if (os[:family] == 'redhat' && os[:release][0] == '7') ||
                      (os[:family] == 'ubuntu' && os[:release].to_f >= 16.04) ||
                      (os[:family] == 'debian' && os[:release].to_f >= 8.0) ||
                      os[:family] == 'fedora'
                     "redis@#{redis_port}"
                   else
                     "redis#{redis_port}"
                   end
    expect(service service_name).to be_enabled
    expect(service service_name).to be_running, if: os[:family] != 'fedora'
  end

  # We use grep and commands here, since serverspec only checks systemd on fedora 20
  # instead of also being able to check sysv style init systems.
  describe command("ps aux | grep -v grep | grep 'redis-server' | grep '*:#{redis_port}'"), if: os[:family] == 'fedora' do
    its(:exit_status) { should eq(0) }
  end

  it "is listening on port #{redis_port}" do
    expect(port redis_port).to be_listening
  end
end
