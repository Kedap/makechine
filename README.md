# MAKECHINE
Un script para la creacion de contenedores que se ejecutan con systemd-nspawn y con ayuda de [snr](https://github.com/mikhailnov/snr) para tener integracion con el xserver, basado en este [gist](https://gist.github.com/Edu4rdSHL/bd9c2dcabbe1846fb55ff72340d3da9c).

## Utilizacion
El script esta pensado para ser ejecutado en archlinux, por el momento, para descargar el script

```
curl -O https://raw.githubusercontent.com/Kedap/makechine/main/makechine.sh
```
O de igual manera lo puedes intalar con la herramienta [apmpkg](https://github.com/kedap/apmpkg) con el siguiente comando:
```
apmpkg instalar -u https://raw.githubusercontent.com/Kedap/makechine/main/makechine.adi
```

Despues damos permisos de ejecucion y ejecutamos

`chmod +x makechine.sh`
`sudo ./makechine.sh help`

Si es la primera vez que se ejecuta este script, ejecuta:

`sudo ./makechine.sh depeni`

Para instalar y descargar las dependencias asi como los archivos necesarios para su uso.

En el caso que querramos hacer un contenedor de debian:

`sudo ./makechine.sh crear debian contenedor_prueba`

O un contenedor arch:

`sudo ./makechine.sh crear arch contenedor_prueba`

En el caso de crear un contenedor arch, [lee esto](https://wiki.archlinux.org/index.php/Systemd-nspawn#Root_login_fails)

Por el momento el script es capaz de crear contenedores de archlinux, debian, kali linux y ubuntu. Proximamente mas OS...!
