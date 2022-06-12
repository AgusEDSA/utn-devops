#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
sudo apt-get update -y

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common linux-image-extra-virtual-hwe-$(lsb_release -r |awk  '{ print $2 }') linux-image-extra-virtual

#Desintalo el servidor web instalado previamente en la unidad 1
if [ -x "$(command -v apache2)" ];then
	sudo apt-get remove --purge apache2 -y
	sudo apt autoremove -y
fi

if [ ! -d "/var/db/mysql" ]; then
	sudo mkdir -p /var/db/mysql
fi

if [ -f "/tmp/ufw" ]; then
	sudo mv -f /tmp/ufw /etc/default/ufw
fi

if [ -f "/tmp/etc_hosts.txt" ]; then
	sudo mv -f /tmp/etc_hosts.txt /etc/hosts
fi

### Configuración del entorno ###

##Genero una partición swap. Previene errores de falta de memoria
if [ ! -f "/swapdir/swapfile" ]; then
	sudo mkdir /swapdir
	cd /swapdir
	sudo dd if=/dev/zero of=/swapdir/swapfile bs=1024 count=2000000
	sudo mkswap -f  /swapdir/swapfile
	sudo chmod 600 /swapdir/swapfile
	sudo swapon swapfile
	echo "/swapdir/swapfile       none    swap    sw      0       0" | sudo tee -a /etc/fstab /etc/fstab
	sudo sysctl vm.swappiness=10
	echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
fi

# ruta raíz del servidor web
APACHE_ROOT="/var/www"
# ruta de la aplicación
APP_PATH="$APACHE_ROOT/UTN-devops-app"

# descargo la app del repositorio
if [ ! -d "$APP_PATH" ]; then
	sudo mkdir /var/www
	echo "clono el repositorio"
	cd $APACHE_ROOT
	sudo git clone https://github.com/AgusEDSA/UTN-devops-app.git
	cd $APP_PATH
	sudo git checkout unidad-2
fi

# Puppet
PUPPET_DIR="/etc/puppet"
ENVIRONMENT_DIR="${PUPPET_DIR}/code/environments/production"
PUPPET_MODULES="${ENVIRONMENT_DIR}/modules"
if [ ! -x "$(command -v puppet)" ]; then
  #configuración de repositorio
	sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
 	sudo apt-get update
	sudo apt install -y puppetmaster

	#### Instalacion puppet agent
	sudo apt install -y puppet

  # Esto es necesario en entornos reales para posibilitar la sincronizacion
  # entre master y agents
	sudo timedatectl set-timezone America/Argentina/Buenos_Aires
	sudo apt-get -y install ntp
	sudo systemctl restart ntp

  # Muevo el archivo de configuración de Puppet al lugar correspondiente
  sudo mv -f /tmp/puppet-master.conf $PUPPET_DIR/puppet.conf

  # elimino certificados de que se generan en la instalación.
  # no nos sirven ya que el certificado depende del nombre que se asigne al maestro
  # y en este ejemplo se modifico.
  sudo rm -rf /var/lib/puppet/ssl

  # Agrego el usuario puppet al grupo de sudo, para no necesitar password al reiniciar un servicio
  sudo usermod -a -G sudo,puppet puppet

  # Estructura de directorios para crear el entorno de Puppet
  sudo mkdir -p $ENVIRONMENT_DIR/{manifests,modules,hieradata}
  sudo mkdir -p $PUPPET_MODULES/docker_install/{manifests,files}

  # Estructura de directorios para crear el modulo de Jenkins
  sudo mkdir -p $PUPPET_MODULES/jenkins/{manifests,files}

  sudo mv -f /tmp/init_jenkins.pp $PUPPET_MODULES/jenkins/manifests/init.pp
  sudo cp /usr/share/doc/puppet/examples/etckeeper-integration/*commit* $PUPPET_DIR
  sudo chmod 755 $PUPPET_DIR/etckeeper-commit-p*
fi

# muevo los archivos que utiliza Puppet
if [ -f "/tmp/site.pp" ]; then
  sudo cp -f /tmp/site.pp $ENVIRONMENT_DIR/manifests
fi

if [ -f "/tmp/init.pp" ]; then
  sudo cp -f /tmp/init.pp $PUPPET_MODULES/docker_install/manifests/init.pp
fi

if [ -f "/tmp/env" ]; then
  sudo cp -f /tmp/env $PUPPET_MODULES/docker_install/files
fi
if [ -f "/tmp/init_jenkins.pp" ]; then
  sudo cp -f /tmp/init_jenkins.pp $PUPPET_MODULES/jenkins/manifests/init.pp
fi
if [ -f "/tmp/jenkins_dependencies.pp" ]; then
  sudo cp -f /tmp/jenkins_dependencies.pp $PUPPET_MODULES/jenkins/manifests/dependencies.pp
fi


sudo ufw allow 8140/tcp

# al detener e iniciar el servicio se regeneran los certificados
echo "Reiniciando servicios puppetmaster y puppet agent"
sudo systemctl stop puppetmaster && sudo systemctl start puppetmaster
sudo systemctl stop puppet && sudo systemctl start puppet

echo "Instalacion modulo sudo"
sudo puppet module install saz-sudo

# limpieza de configuración del dominio utn-devops.localhost es nuestro nodo agente.
# en nuestro caso es la misma máquina
sudo puppet node clean utn-devops.localhost

# Habilito el agente
sudo puppet agent --certname utn-devops.localhost --enable

