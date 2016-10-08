require_relative '../tests/spec_helper'

pip_version = '8.1'
cname = ENV['container_name']

describe command("docker exec #{cname} pip --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{pip_version}/ }
end
