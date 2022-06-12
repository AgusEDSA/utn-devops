# GRUPO 7
Vagrant.configure("2") do |config|

  config.vm.box = "hashicorp/bionic64"


  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 4400, host: 4400
  config.vm.network "forwarded_port", guest: 8082, host: 8082
  config.vm.network "forwarded_port", guest: 8140, host: 8140


  config.vm.hostname = "utn-devops.localhost"
  config.vm.boot_timeout = 3600
  config.vm.provider "virtualbox" do |v|
	v.name = "utn-devops-vagrant-ubuntu"
  end


  config.vm.synced_folder ".", "/vagrant"


  config.vm.provider "virtualbox" do |vb|

    vb.memory = "1024"
	vb.cpus = 2

  end

  config.vm.provision "file", source: "hostConfigs/ufw", destination: "/tmp/ufw"
  config.vm.provision "file", source: "hostConfigs/etc_hosts.txt", destination: "/tmp/etc_hosts.txt"

  config.vm.provision "file", source: "hostConfigs/puppet/site.pp", destination: "/tmp/site.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/init.pp", destination: "/tmp/init.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/init_jenkins.pp", destination: "/tmp/init_jenkins.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/jenkins_dependencies.pp", destination: "/tmp/jenkins_dependencies.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/puppet-master.conf", destination: "/tmp/puppet-master.conf"
  config.vm.provision "file", source: "hostConfigs/puppet/.env", destination: "/tmp/env"

  config.vm.provision :shell, path: "Vagrant.bootstrap.sh"


end
