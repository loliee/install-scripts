require_relative '../tests/spec_helper'

etcd_version = '2.3.7'
cname = ENV['container_name']

describe command("docker exec #{cname} /usr/local/bin/etcd --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{etcd_version}/ }
end

describe command("docker exec #{cname} cat /root/.versions/etcd") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{etcd_version}/ }
end

describe command("docker exec #{cname} cat /etc/init/etcd.conf") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /description "Etcd service"/ }
  its(:stdout) { should match /author "@loliee"/ }
end

describe command("docker exec #{cname} cat /etc/default/etcd") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /ETCD_OPTS=""/ }
end
