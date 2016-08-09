require_relative '../tests/spec_helper'

stow_version = '2.2.2'
cname = ENV['container_name']

describe command("docker exec #{cname} /usr/local/bin/stow --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{stow_version}/ }
end

describe command("docker exec #{cname} cat /root/.versions/stow") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{stow_version}/ }
end
