require_relative '../tests/spec_helper'

albert_version = 'v0.8.11'
cname = ENV['container_name']

describe command("docker exec #{cname} cat /root/.versions/albert") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{albert_version}/ }
end

describe command("docker exec #{cname} ls /usr/bin/albert") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} ls /usr/share/albert") do
  its(:exit_status) { should eq 0 }
end
