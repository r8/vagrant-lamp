require 'spec_helper'

prefix = os[:family] == 'freebsd' ? '/usr/local' : ''

describe 'Redis-Sentinel' do
  it_behaves_like 'sentinel on port', 26379, 'cluster'
end

describe file("#{prefix}/etc/redis/sentinel_cluster.conf") do
  [
    %r{sentinel monitor master6379 127.0.0.1 6379 2},
    %r{sentinel down-after-milliseconds master6379 30000},
    %r{sentinel parallel-syncs master6379 1},
    %r{sentinel failover-timeout master6379 900000},
    %r{sentinel monitor master6380 127.0.0.1 6380 2},
    %r{sentinel down-after-milliseconds master6380 30000},
    %r{sentinel parallel-syncs master6380 1},
    %r{sentinel failover-timeout master6380 900000}
  ].each do |pattern|
    its(:content) { should match(pattern) }
  end
end

unless (os[:family] == 'redhat' && os[:release][0] == '7') ||
       os[:family] == 'freebsd' ||
       (os[:family] == 'ubuntu' && os[:release].to_f >= 16.04) ||
       (os[:family] == 'debian' && os[:release].to_f >= 8.0) ||
       os[:family] == 'fedora'
  describe file('/etc/init.d/redis_sentinel_cluster') do
    [
      %r{SENTINELNAME=sentinel_cluster},
      %r{EXEC="(su -s /bin/sh)|(runuser redis) -c \\?["']/usr/local/bin/redis-server /etc/redis/\$\{SENTINELNAME\}.conf --sentinel\\?["']( redis)?"},
      %r{PIDFILE=/var/run/redis/sentinel_cluster/\$\{SENTINELNAME\}.pid},
      %r{mkdir -p /var/run/redis/sentinel_cluster},
      %r{chown redis  /var/run/redis/sentinel_cluster}
    ].each do |pattern|
      its(:content) { should match(pattern) }
    end
  end
end

describe command('/usr/local/bin/redis-cli --raw -p 26379 SENTINEL MASTER master6379') do
  [
    %r{name},
    %r{master6379},
    %r{ip},
    %r{127.0.0.1},
    %r{port},
    %r{6379},
    %r{flags},
    %r{master},
    %r{last-ping-sent},
    %r{last-ok-ping-reply},
    %r{last-ping-reply},
    %r{down-after-milliseconds},
    %r{30000},
    %r{role-reported},
    %r{master},
    %r{config-epoch},
    %r{0},
    %r{num-slaves},
    %r{0},
    %r{num-other-sentinels},
    %r{0},
    %r{quorum},
    %r{2},
    %r{failover-timeout},
    %r{900000},
    %r{parallel-syncs},
    %r{1}
  ].each do |pattern|
    its(:stdout) { should match(pattern) }
  end
end

describe command('/usr/local/bin/redis-cli --raw -p 26379 SENTINEL MASTER master6380') do
  [
    %r{name},
    %r{master6380},
    %r{ip},
    %r{127.0.0.1},
    %r{port},
    %r{6380},
    %r{flags},
    %r{master},
    %r{last-ping-sent},
    %r{last-ok-ping-reply},
    %r{last-ping-reply},
    %r{down-after-milliseconds},
    %r{30000},
    %r{role-reported},
    %r{master},
    %r{config-epoch},
    %r{0},
    %r{num-slaves},
    %r{0},
    %r{num-other-sentinels},
    %r{0},
    %r{quorum},
    %r{2},
    %r{failover-timeout},
    %r{900000},
    %r{parallel-syncs},
    %r{1}
  ].each do |pattern|
    its(:stdout) { should match(pattern) }
  end
end
