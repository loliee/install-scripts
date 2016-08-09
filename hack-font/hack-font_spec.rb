require_relative '../tests/spec_helper'

hack_version = '2.020'
cname = ENV['container_name']

describe command("docker exec #{cname} ls /usr/share/fonts/") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /Hack-Bold.ttf/ }
  its(:stdout) { should match /Hack-BoldItalic.ttf/ }
  its(:stdout) { should match /Hack-Italic.ttf/ }
  its(:stdout) { should match /Hack-Regular.ttf/ }
end

describe command("docker exec #{cname} cat /root/.versions/hack-font") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{hack_version}/ }
end
