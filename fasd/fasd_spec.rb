require_relative '../tests/spec_helper'

fasd_version = '1.0.1'
cname = ENV['container_name']

describe command("docker exec #{cname} /usr/local/bin/fasd --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{fasd_version}/ }
end

describe command("docker exec #{cname} cat /root/.versions/fasd") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{fasd_version}/ }
end

describe command("docker exec #{cname} ls /usr/local/src/fasd") do
  its(:exit_status) { should eq 0 }
end
