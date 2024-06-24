#!/bin/bash

# Cargar variables del archivo .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

local_mount_point="$LOCAL_MOUNT_POINT"
remote_mount_point="$REMOTE_MOUNT_POINT"
identity_file="$IDENTITY_FILE"

function printMessage() {
    case $2 in
        "INFO")
            echo -e "\e[32m$1\e[0m"
            ;;
        "ERROR")
            echo -e "\e[31m$1\e[0m"
            ;;
        "WARNING")
            echo -e "\e[33m$1\e[0m"
            ;;
        *)
            echo "$1"
            ;;
    esac
}

printMessage "Bienvenido" "INFO"

sudo -v

printMessage "Validando software necesario" "INFO"
if ! command -v sshfs &> /dev/null; then
    sudo apt install sshfs -y
fi

printMessage "Verificando si el punto de montaje local existe" "INFO"
mkdir -p "$local_mount_point"

printMessage "Activando el uso de la carpeta remota como si fuera local." "INFO"
sshfs "$remote_mount_point" "$local_mount_point" -o IdentityFile="$identity_file"

# Imprime el comando ejecutado
printMessage "Comando ejecutado: sshfs $remote_mount_point $local_mount_point -o IdentityFile=$identity_file" "WARNING"

printMessage "Verificando el resultado de configuración" "INFO"

if [ $? -eq 0 ]; then
    printMessage "Montaje exitoso en $local_mount_point" "INFO"
else
    printMessage "Error al montar la carpeta remota" "ERROR"
fi
