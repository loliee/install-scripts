require_relative '../tests/spec_helper'

lacapitaine_version = '0.3.0'
cname = ENV['container_name']

describe command("docker exec #{cname} ls /root/.icons/la-capitaine-icon-theme-0.3.0") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} cat /root/.versions/lacapitaine") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{lacapitaine_version}/ }
end
