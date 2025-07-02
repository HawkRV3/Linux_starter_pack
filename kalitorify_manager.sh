#!/bin/bash

# Script interactivo para gestionar Kalitorify
# Versión actualizada con instalación oficial por make
# Autor: ChatGPT para Ipgamer 138

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

check_installed() {
    if command -v kalitorify &> /dev/null; then
        return 0
    else
        return 1
    fi
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
    cd "$KALI_DIR" || { echo -e "${RED}[✖] No se pudo entrar al directorio ${KALI_DIR}.${RESET}"; return 1; }

    sudo make install

    if command -v kalitorify &> /dev/null; then
        echo -e "${GREEN}[✔] Kalitorify instalado correctamente y accesible globalmente.${RESET}"
    else
        echo -e "${RED}[✖] Kalitorify no se encuentra en el PATH.${RESET}"
    fi
}

activate_kalitorify() {
    echo -e "${CYAN}[+] Ejecutando: kalitorify --start${RESET}"
    sudo kalitorify --start
}

stop_kalitorify() {
    echo -e "${CYAN}[+] Ejecutando: kalitorify --stop${RESET}"
    sudo kalitorify --stop
}

status_kalitorify() {
    echo -e "${CYAN}[+] Ejecutando: kalitorify --status${RESET}"
    sudo kalitorify --status
}

flush_kalitorify() {
    echo -e "${CYAN}[+] Ejecutando: kalitorify --flush${RESET}"
    sudo kalitorify --flush
}

customize_kalitorify() {
    echo -e "${YELLOW}[!] Editando el script de Kalitorify...${RESET}"
    if [ -f "$KALI_DIR/kalitorify" ]; then
        sudo nano "$KALI_DIR/kalitorify"
    else
        echo -e "${RED}[✖] No se encontró el archivo en $KALI_DIR/kalitorify${RESET}"
    fi
}

remove_kalitorify() {
    echo -e "${RED}[!] Desinstalando Kalitorify...${RESET}"
    sudo make -C "$KALI_DIR" uninstall
    rm -rf "$KALI_DIR"
    echo -e "${GREEN}[✔] Kalitorify eliminado.${RESET}"
}

main_menu() {
    while true; do
        clear
        banner
        echo "1. Instalar Kalitorify"
        echo "2. Activar red TOR (kalitorify --start)"
        echo "3. Detener red TOR (kalitorify --stop)"
        echo "4. Ver estado (kalitorify --status)"
        echo "5. Limpiar iptables (kalitorify --flush)"
        echo "6. Personalizar Kalitorify"
        echo "7. Eliminar Kalitorify"
        echo "8. Salir"
        echo -n -e "\nSelecciona una opción: "
        read -r opcion
        case $opcion in
            1) install_kalitorify ;;
            2) check_installed && activate_kalitorify || echo -e "${RED}[✖] Kalitorify no está instalado.${RESET}" ;;
            3) check_installed && stop_kalitorify || echo -e "${RED}[✖] Kalitorify no está instalado.${RESET}" ;;
            4) check_installed && status_kalitorify || echo -e "${RED}[✖] Kalitorify no está instalado.${RESET}" ;;
            5) check_installed && flush_kalitorify || echo -e "${RED}[✖] Kalitorify no está instalado.${RESET}" ;;
            6) customize_kalitorify ;;
            7) remove_kalitorify ;;
            8) echo "¡Hasta luego!"; exit 0 ;;
            *) echo -e "${RED}Opción inválida.${RESET}" ;;
        esac
        pause
    done
}

# Ejecutar menú principal
main_menu
