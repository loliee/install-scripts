require_relative '../tests/spec_helper'

cname = ENV['container_name']

describe command("docker exec #{cname} ls /usr/local/bin/sshrc") do
  its(:exit_status) { should eq 0 }
end
