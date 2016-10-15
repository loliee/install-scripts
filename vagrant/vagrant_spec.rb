require_relative '../tests/spec_helper'

vagrant_version = '1.8.5'
cname = ENV['container_name']

describe command("docker exec #{cname} vagrant --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{vagrant_version}/ }
end

describe command("docker exec #{cname} cat /root/.versions/vagrant") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{vagrant_version}/ }
end
