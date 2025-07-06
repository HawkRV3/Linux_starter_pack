#!/bin/bash

# Script simplificado para instalar y eliminar Kalitorify
# Autor: Ian

REPO_URL="https://github.com/brainfucksec/kalitorify.git"
KALI_DIR="./kalitorify"

# Colores
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

banner() {
    echo -e "${CYAN}"
    echo "======================================"
    echo "     🔥 KALITORIFY MANAGER 🔥"
    echo "======================================"
    echo -e "${RESET}"
}

pause() {
    echo -e "\nPresiona [ENTER] para continuar..."
    read
}

install_kalitorify() {
    echo -e "${CYAN}[+] Clonando Kalitorify en el directorio actual...${RESET}"
    git clone "$REPO_URL" || {
        echo -e "${RED}[✖] Error al clonar el repositorio.${RESET}"
        return 1
    }

    echo -e "${CYAN}[+] Actualizando el sistema e instalando dependencias...${RESET}"
    sudo apt-get update && sudo apt-get dist-upgrade -y
    sudo apt-get install -y tor curl make

    echo -e "${CYAN}[+] Instalando Kalitorify con make...${RESET}"
    cd "$KALI_DIR" || {
        echo -e "${RED}[✖] No se pudo entrar al directorio $KALI_DIR.${RESET}"
        return 1
    }

    sudo make install

    if command -v kalitorify &> /dev/null; then
        echo -e "${GREEN}[✔] Kalitorify instalado correctamente.${RESET}"
    else
        echo -e "${RED}[✖] Kalitorify no se encuentra en el PATH.${RESET}"
    fi
}

remove_kalitorify() {
    echo -e "${RED}[!] Desinstalando Kalitorify...${RESET}"
    
    if [ -d "$KALI_DIR" ]; then
        echo -e "${YELLOW}[i] Ejecutando make uninstall desde $KALI_DIR...${RESET}"
        sudo make -C "$KALI_DIR" uninstall
        rm -rf "$KALI_DIR"
    else
        echo -e "${YELLOW}[!] No se encontró el directorio git. Procediendo con eliminación manual.${RESET}"
        sudo rm -ri /usr/bin/kalitorify \
                   /usr/share/kalitorify \
                   /usr/share/doc/kalitorify \
                   /var/lib/kalitorify
    fi

    echo -e "${GREEN}[✔] Kalitorify eliminado.${RESET}"
}

main_menu() {
    while true; do
        clear
        banner
        echo "1. Instalar Kalitorify"
        echo "2. Eliminar Kalitorify"
        echo "3. Salir"
        echo -n -e "\nSelecciona una opción: "
        read -r opcion
        case $opcion in
            1) install_kalitorify ;;
            2) remove_kalitorify ;;
            3) echo "¡Hasta luego!"; exit 0 ;;
            *) echo -e "${RED}Opción inválida.${RESET}" ;;
        esac
        pause
    done
}

# Ejecutar menú principal
main_menu
