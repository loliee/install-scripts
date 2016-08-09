require_relative '../tests/spec_helper'

kubernetes_version = '1.3.8'
cname = ENV['container_name']

describe command("docker exec #{cname} cat /root/.versions/kubernetes") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{kubernetes_version}/ }
end

describe command("docker exec #{cname} ls /usr/local/bin/kube-apiserver") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} cat /etc/init/kube-apiserver.conf") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /description "Kube-Apiserver service"/ }
  its(:stdout) { should match /author "@loliee"/ }
end

describe command("docker exec #{cname} cat /etc/default/kube-apiserver") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /KUBE_APISERVER_OPTS=""/ }
end

describe command("docker exec #{cname} ls /usr/local/bin/kube-controller-manager") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} cat /etc/init/kube-controller-manager.conf") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /description "Kube-Controller-Manager service"/ }
  its(:stdout) { should match /author "@loliee"/ }
end

describe command("docker exec #{cname} cat /etc/default/kube-controller-manager") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /KUBE_CONTROLLER_MANAGER_OPTS=""/ }
end

describe command("docker exec #{cname} ls /usr/local/bin/kube-scheduler") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} cat /etc/init/kube-scheduler.conf") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /description "Kube-Scheduler service"/ }
  its(:stdout) { should match /author "@loliee"/ }
end

describe command("docker exec #{cname} cat /etc/default/kube-scheduler") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /KUBE_SCHEDULER_OPTS=""/ }
end

describe command("docker exec #{cname} ls /usr/local/bin/kube-proxy") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} cat /etc/init/kube-proxy.conf") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /description "Kube-Proxy service"/ }
  its(:stdout) { should match /author "@loliee"/ }
end

describe command("docker exec #{cname} cat /etc/default/kube-proxy") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /KUBE_PROXY_OPTS=""/ }
end

describe command("docker exec #{cname} ls /usr/local/bin/kubelet") do
  its(:exit_status) { should eq 0 }
end

describe command("docker exec #{cname} cat /etc/init/kubelet.conf") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /description "Kubelet service"/ }
  its(:stdout) { should match /author "@loliee"/ }
end

describe command("docker exec #{cname} cat /etc/default/kubelet") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /KUBELET_OPTS=""/ }
end
