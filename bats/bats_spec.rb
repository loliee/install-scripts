require_relative '../tests/spec_helper'

bats_version = '0.4.0'
cname = ENV['container_name']

describe command("docker exec #{cname} /usr/local/bin/bats --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{bats_version}/ }
end

describe command("docker exec #{cname} cat /root/.versions/bats") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{bats_version}/ }
end
