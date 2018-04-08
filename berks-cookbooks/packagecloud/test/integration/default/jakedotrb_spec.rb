path = '/usr/local/bin/jakedotrb'

describe command("ls #{path}") do
  its(:exit_status) { should eq 0 }
end

describe command(path) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /jake douglas is a very nice young man./ }
end
