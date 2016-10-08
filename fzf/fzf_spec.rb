require_relative '../tests/spec_helper'

fzf_version = '0.15.4'
cname = ENV['container_name']

describe command("docker exec #{cname} /usr/local/bin/fzf --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{fzf_version}/ }
end

describe command("docker exec #{cname} cat /root/.versions/fzf") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{fzf_version}/ }
end

describe command("docker exec #{cname} ls /usr/local/src/fzf") do
  its(:exit_status) { should eq 0 }
end
