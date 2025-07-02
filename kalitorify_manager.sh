#!/bin/bash

# Script interactivo para gestionar Kalitorify
# Autor: ChatGPT para Ipgamer 138

REPO_URL="https://github.com/brainfucksec/kalitorify.git"
INSTALL_DIR="/opt/kalitorify"

# Colores
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

banner() {
    echo -e "${CYAN}"
    echo "======================================"
    echo "    🔥 KALITORIFY MANAGER 🔥"
    echo "======================================"
    echo -e "${RESET}"
}

pause() {
    echo -e "\nPresiona [ENTER] para continuar..."
    read
}

check_installed() {
    if [ -d "$INSTALL_DIR" ]; then
        return 0
    else
        return 1
    fi
}

install_kalitorify() {
    echo -e "${CYAN}[+] Instalando Kalitorify...${RESET}"
    sudo apt update
    sudo apt install -y tor curl iptables
    sudo git clone "$REPO_URL" "$INSTALL_DIR"
    sudo chmod +x "$INSTALL_DIR/kalitorify"
    sudo ln -sf "$INSTALL_DIR/kalitorify" /usr/local/bin/kalitorify
    echo -e "${GREEN}[✔] Instalación completada.${RESET}"
}

activate_kalitorify() {
    echo -e "${CYAN}[+] Activando Kalitorify...${RESET}"
    sudo kalitorify --start
}

stop_kalitorify() {
    echo -e "${CYAN}[+] Deteniendo Kalitorify...${RESET}"
    sudo kalitorify --stop
}

status_kalitorify() {
    echo -e "${CYAN}[i] Estado de Kalitorify:${RESET}"
    sudo kalitorify --status
}

customize_kalitorify() {
    echo -e "${YELLOW}[!] Personalización: se editará el script directamente.${RESET}"
    echo "Editando archivo con nano (usa con precaución)..."
    sudo nano "$INSTALL_DIR/kalitorify"
}

remove_kalitorify() {
    echo -e "${RED}[!] Eliminando Kalitorify...${RESET}"
    sudo rm -f /usr/local/bin/kalitorify
    sudo rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}[✔] Kalitorify eliminado.${RESET}"
}

main_menu() {
    while true; do
        clear
        banner
        echo "1. Instalar Kalitorify"
        echo "2. Activar Kalitorify (start)"
        echo "3. Detener Kalitorify (stop)"
        echo "4. Mostrar estado (status)"
        echo "5. Personalizar Kalitorify"
        echo "6. Eliminar Kalitorify"
        echo "7. Salir"
        echo -n -e "\nSelecciona una opción: "
        read -r opcion
        case $opcion in
            1) install_kalitorify ;;
            2) activate_kalitorify ;;
            3) stop_kalitorify ;;
            4) status_kalitorify ;;
            5) customize_kalitorify ;;
            6) remove_kalitorify ;;
            7) echo "¡Hasta luego!"; exit 0 ;;
            *) echo -e "${RED}Opción inválida.${RESET}" ;;
        esac
        pause
    done
}

# Ejecutar menú principal
main_menu
