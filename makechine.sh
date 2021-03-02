#!/bin/bash
# Codificado en utf-8

# [ user@archlinux ~ ]$ sudo makechine help

########################################################################
#                                                                      #
# makechine: Un simple script de bash para la creacion de contenedores #
# de OS utilizando systemd-nspawn y snr, mas info:                     #
# https://wiki.archlinux.org/index.php/Systemd-nspawn                  #
# https://gist.github.com/Edu4rdSHL/bd9c2dcabbe1846fb55ff72340d3da9c   #
# https://github.com/mikhailnov/snr                                    #
#                                                                      #
# Autor kedap <dxhqezk@hi2.in>                                         #
#                                                                      #
########################################################################

# Este scirpt esta desarrollado para sistemas basados en archlinux

# Variables de cajon
NOMBRE='makechine'
VERSION='1.0-beta'
TRUE=1
FALSE=0
VERBOSE='/dev/null'
#VERBOSE='/dev/stdout'
ROJO='\033[91m'
VERDE='\033[92m'
AMARILLO='\033[93m'
AZUL='\033[94m'
CYAN='\033[96m'
BLANCO='\033[0m'

# Variables
RUTA=''

install_depen(){
	# Puede cambiar
	echo -e $VERDE"Instalando dependencias..."
	echo "Llaves de debian y ubuntu"
	pacman -S jetring git arch-install-scripts debootstrap debian-archive-keyring ubuntu-keyring --noconfirm > $VERBOSE 2>&1
	echo "Descargando e instalando llaves de kali linux..."
	git clone https://gitlab.com/kalilinux/packages/kali-archive-keyring /tmp/kali
	make -sC /tmp/kali
	make install -sC /tmp/kali
	echo "Descargando snr..."
	curl -so /usr/bin/snr https://raw.githubusercontent.com/mikhailnov/snr/master/snr.sh
	chmod +x /usr/bin/snr
	echo -e $AZUL"[?] Escribe la ruta en donde estaran almacenadas las maquinas (por defecto ~/machines/:"
	read -r RUTA
	
	# Opcion por defecto
	if [ -z "$RUTA" ]; then
		echo -e $AMARILLO'Selecionando ~/machines/ (opcion por defeto)'
		RUTA=$HOME/machines
	fi

	echo -e $AMARILLO"Creando el archivo de configuracion de snr (/etc/snr.conf)"
	echo "#!/bin/sh
# Config file for snr" > /etc/snr.conf
	echo 'DIR='$RUTA >> /etc/snr.conf
	echo '# NW - network
# NW=0 - disable binding to network bridge
# NW=1 - enable binding to network bridge
# NW=2 - force binding to network bridge even if not booting
#NW=1
#BRIDGE=virbr0

# Mount-bind additional directories
#bind_options="--bind=/mnt/dev --bind=/tmp/snr"
# Any other additional default options for systemd-nspawn,
# e.g. always boot containers (or maybe setup network etc.)' >> /etc/snr.conf
	echo 'other_options="--boot --capability=CAP_NET_ADMIN"' >> /etc/snr.conf
	echo '#CMD_NSPAWN="systemd-nspawn"
#CMD_READELF="readelf"
#CMD_TEST="test"
#X11_SOCKET_DIR="/tmp/.X11-unix"
#PULSE_SERVER_TARGET="/tmp/snr_PULSE_SERVER"
#SUDO_CMD="$(command -v sudo)"' >> /etc/snr.conf
	echo -e $VERDE"Instacion completada!"
}

os_arch(){
	echo -e $AMARILLO"[i] Iniciando descarga del contenedor de archlinux..."
	source /etc/snr.conf
	contfolder=$DIR/$@
	mkdir -p $contfolder
	pacstrap -c $contfolder base
	echo -e $ROJO"[!] Cuando se inicie el contenedor deberas de borrar los siguiestes archivos:"
	echo "/etc/securetty"
	echo "/usr/share/factory/etc/securetty"
	echo -e "\nY asi mismo editar el archivo /etc/pacman.conf. De que la linea que dice NoExtract configurar lo siguiente"
	echo "/usr/share/factory/etc/securetty"
	echo -e $BLANCO"ENTER para seguir con el proceso"
	read hola
}

os_debian(){
	echo -e $AMARILLO"[i] Iniciando descarga del contenedor de debian..."
	source /etc/snr.conf
	contfolder=$DIR/$@
	mkdir -p $contfolder
	debootstrap --include=systemd-container --components=main,universe,non-free,contrib sid $contfolder http://ftp.de.debian.org/debian
	echo -e $BLANCO"[i] Se ha terminado de descargar el contenedor de Debian sid."
}

os_ubuntu(){
	echo -e $AMARILLO"[i] Iniciando descarga del contenedor de ubuntu..."
	source /etc/snr.conf
	contfolder=$DIR/$@
	mkdir -p $contfolder
	debootstrap --include=systemd-container --components=main,universe,contrib,non-free focal $contfolder http://archive.ubuntu.com/ubuntu/
	echo -e $BLANCO"[i] Se ha terminado de descargar el contenedor de ubuntu focal"
}

os_kali(){
	echo -e $AMARILLO"[i] Iniciando descarga del contenedor de kali linux"
	source /etc/snr.conf
	contfolder=$DIR/$@
	mkdir -p $contfolder
	debootstrap --include=systemd-container --components=main,non-free,contrib kali-rolling $contfolder http://http.kali.org/kali
	echo -e $BLANCO"[i] Se ha terminado de descargar el contenedor de Kali linux"
}

machine_status(){
	machinectl
}

conte_noboot(){
	source /etc/snr.conf
	contfolder=$DIR/$@
	systemd-nspawn -D $contfolder
}

conte_exe(){
	echo -e $AMARILLO"Puedes mejor ejecutar:"
	echo -e $BLANCO"snr <machine>"
	snr $@
}

borrar_conte(){
	source /etc/snr.conf
	contfolder=$DIR/$@
	rm -r $contfolder
}

help_menu(){
	echo -e $BLANCO"Uso: makechine [Comando] <Argumentos...>"
	echo "Comandos:"
	echo -e "\ndepeni:	Descarga e instala las dependencias para que makechine funcione"
	echo "crear:	Uso: crear <arch | debian | kali | ubuntu> <nombre de la maquina>"
	echo "borrar:	Uso: borrar <nombre de la maquina> Borra el contenedor"
	echo "exec:		Uso: exec <nombre de la maquina> Corre el contenedor de manera NO booteable"
	echo "boot:		Uso: boot <nombre de la maquina> Bootea un contenedor, pero de igual manera se recomienta utilizar snr <nombre de la maquina>"
	echo "status:	Mostrara el status de las maquinas posibles"
	echo -e $CYAN "\n\nEste es un simple script que integra systemd-nspawn y snr para la interfaz grafica"
}

create(){
	case $1 in
		"arch" )
			os_arch $2 
			;;
		"debian")
			os_debian $2
			;;
		"kali")
			os_kali $2
			;;
		"ubuntu")
			os_ubuntu $2
			;;
	esac
}

main(){
	case $1 in
		"depeni")
			install_depen
			;;
		"crear")
			create $2 $3
			;;
		"borrar")
			borrar_conte $2
			;;
		"exec")
			conte_noboot $2 $3
			;;
		"boot")
			conte_exe $2 
			;;
		"help")
			help_menu
			;;
		"status")
			machine_status
			;;
		*)
			echo "Intenta con makechine help";;
	esac
}

#|| Nosotros
#|| Empezamos de 
#\/ Aqui
main $@