# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "generic/rocky9"
  config.vm.box_version = "4.3.12"

  config.vm.define "k8s" do |k8s|
    k8s.vm.hostname = "k8s"
    k8s.vm.network "private_network", ip: "192.168.56.10"

    k8s.vm.network "forwarded_port", guest: 80, host: 8080
    k8s.vm.network "forwarded_port", guest: 443, host: 8443

    k8s.vm.disk :disk, size: "100GB", primary: true
    
    k8s.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 4
    end

    k8s.vm.provision "ansible" do |ansible|
      ansible.playbook = "site.yml"
      ansible.vault_password_file = ".vault_pass"
      ansible.groups = {
        "k8s_master" => ["k8s"],
        "k8s_nodes" => ["k8s"]
      }
      ansible.extra_vars = {
        kubernetes_version: "latest",
        pod_network_cidr: "10.244.0.0/16"
      }
    end
  end
end
