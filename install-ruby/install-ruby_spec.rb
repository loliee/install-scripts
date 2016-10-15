require_relative '../tests/spec_helper'

ruby_version = '2.3.1'
install_ruby_version = '0.6.0'
chruby_version=-'0.3.9'
cname = ENV['container_name']

describe command("docker exec #{cname} /root/.rubies/ruby-2.3.1/bin/ruby --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{ruby_version}/ }
end

describe command("docker exec #{cname} cat /root/.versions/chruby") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{chruby_version}/ }
end

describe command("docker exec #{cname} cat /root/.versions/install-ruby") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{install_ruby_version}/ }
end
describe command("docker exec #{cname} ls /usr/local/share/chruby") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} cat /root/.ruby-version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{ruby_version}/ }
end
