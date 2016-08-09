require_relative '../tests/spec_helper'

vim_version = '8.0.0022'
cname = ENV['container_name']

describe command("docker exec #{cname} /usr/local/bin/vim --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /VIM - Vi IMproved 8.0/ }
  its(:stdout) { should match /\+termguicolors/ }
end

describe command("docker exec #{cname} cat /root/.versions/vim") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{vim_version}/ }
end
