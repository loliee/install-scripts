require_relative '../tests/spec_helper'

docker_version = '1.12'
docker_compose_version = '1.8'
cname = ENV['container_name']

describe command("docker exec #{cname} docker --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{docker_version}/ }
end

describe command("docker exec #{cname} docker-compose --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{docker_compose_version}/ }
end

describe command("docker exec #{cname} cat /root/.versions/docker") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{docker_version}/ }
end
