# GRUPO 7
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"


  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3306, host: 4041
  config.vm.network "forwarded_port", guest: 8080, host: 8090
  config.vm.network "forwarded_port", guest: 4567, host: 4567


  config.vm.hostname = "utn-devops.localhost"
  config.vm.boot_timeout = 3600
  config.vm.provider "virtualbox" do |v|
	v.name = "utn-devops-vagrant-ubuntu"
  end


  config.vm.synced_folder ".", "/vagrant"


  config.vm.provider "virtualbox" do |vb|

    vb.memory = "1024"
  end


  config.vm.provision "file", source: "Configs/devops.site.conf", destination: "/tmp/devops.site.conf"

  config.vm.provision :shell, path: "Vagrant.bootstrap.sh", run: "always"


end
