require_relative '../tests/spec_helper'

cname = ENV['container_name']

describe command("docker exec #{cname} /usr/bin/google-chrome --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /Google Chrome 54.0/ }
end
