require_relative '../tests/spec_helper'

cname = ENV['container_name']

describe command("docker exec #{cname} hash kubeadm") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} hash kubectl") do
  its(:exit_status) { should eq 0 }
end
