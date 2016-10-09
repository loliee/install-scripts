require_relative '../tests/spec_helper'

flannel_version = '0.6.2'
cname = ENV['container_name']

describe command("docker exec #{cname} /usr/local/bin/flanneld --version") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} cat /root/.versions/flannel") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{flannel_version}/ }
end

describe command("docker exec #{cname} cat /etc/init/flanneld.conf") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /description "Flannel service"/ }
  its(:stdout) { should match /author "@loliee"/ }
end

describe command("docker exec #{cname} cat /etc/default/flanneld") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /FLANNEL_OPTS=""/ }
end
