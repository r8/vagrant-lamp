describe command('ls /usr/local/bin/jake') do
  its(:exit_status) { should eq 0 }
end

describe command('/usr/local/bin/jake') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "as it so happens, jake douglas is a very nice young man.\n" }
end

describe command('man jake') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /jake man page/ }
  its(:stdout) { should match /binary executable program/ }
  its(:stdout) { should match /No known bugs/ }
end

if os[:family] == 'ubuntu'
  describe command('ls /home/vagrant/jake_1.0-7.dsc') do
    its(:exit_status) { should eq 0 }
  end

  describe command('ls /home/vagrant/jake_1.0.orig.tar.bz2') do
    its(:exit_status) { should eq 0 }
  end

  describe command('ls /home/vagrant/jake_1.0-7.debian.tar.gz') do
    its(:exit_status) { should eq 0 }
  end
end
