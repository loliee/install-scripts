require_relative '../tests/spec_helper'

tmux_version = '2.3'
cname = ENV['container_name']

describe command("docker exec #{cname} cat /root/.versions/tmux") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{tmux_version}/ }
end

describe command("docker exec #{cname} ls /usr/local/src/tmux") do
  its(:exit_status) { should eq 0 }
end
