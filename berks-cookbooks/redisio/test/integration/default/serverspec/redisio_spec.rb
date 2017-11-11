require 'spec_helper'

prefix = os[:family] == 'freebsd' ? '/usr/local' : ''

describe 'Redis' do
  it_behaves_like 'redis on port', 6379
end

describe file("#{prefix}/etc/redis/savetest.conf") do
  it { should be_file }

  ['save a', 'save b', 'save c'].each do |m|
    its(:content) { should match(m) }
  end
end

if system('command -v semanage &>/dev/null')
  describe command('semanage fcontext --list --noheading | grep -F redis') do
    [
      %r{^/etc/redis\(/\.\*\)\?\s.*:redis_conf_t:},
      %r{^/var/lib/redis\(/\.\*\)\?\s.*:redis_var_lib_t:},
      %r{^/var/run/redis\(/\.\*\)\?\s.*:redis_var_run_t:},
      %r{^/var/log/redis\(/\.\*\)\?\s.*:redis_log_t:}
    ].each do |pattern|
      its(:stdout) { should match(pattern) }
    end
  end
end
