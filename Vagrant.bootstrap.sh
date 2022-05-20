#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
sudo apt-get update

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
APP_PATH="$APACHE_ROOT/utn-devops-app"

# descargo la app del repositorio
if [ ! -d "$APP_PATH" ]; then
	sudo mkdir /var/www
	echo "clono el repositorio"
	cd $APACHE_ROOT
	sudo git clone https://github.com/Fichen/utn-devops-app.git
	cd $APP_PATH
	sudo git checkout unidad-2
fi


######## Instalacion de DOCKER ########
if [ ! -x "$(command -v docker)" ]; then
	sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

	##Configuramos el repositorio
	curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" > /tmp/docker_gpg
	sudo apt-key add < /tmp/docker_gpg && sudo rm -f /tmp/docker_gpg
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	#Actualizo los paquetes con los nuevos repositorios
	sudo apt-get update -y

	#Instalo docker desde el repositorio oficial
	sudo apt-get install -y docker-ce docker-compose

	#Lo configuro para que inicie en el arranque
	sudo systemctl enable docker
fi
