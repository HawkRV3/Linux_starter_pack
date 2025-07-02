#!/bin/bash

# Script interactivo para gestionar Kalitorify desde su repositorio oficial
# Requiere privilegios sudo para algunas acciones

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
    echo "     🔥 KALITORIFY MANAGER 🔥"
    echo "======================================"
    echo -e "${RESET}"
}

pause() {
    echo -e "\nPresiona [ENTER] para continuar..."
    read
}

check_installed() {
    if [ -f "/usr/local/bin/kalitorify" ]; then
        return 0
    else
        return 1
    fi
}

install_kalitorify() {
    echo -e "${CYAN}[+] Instalando Kalitorify desde GitHub...${RESET}"
    sudo apt update
    sudo apt install -y tor curl iptables git
    sudo git clone "$REPO_URL" "$INSTALL_DIR"
    sudo chmod +x "$INSTALL_DIR/kalitorify"
    sudo ln -sf "$INSTALL_DIR/kalitorify" /usr/local/bin/kalitorify
    echo -e "${GREEN}[✔] Kalitorify instalado correctamente.${RESET}"
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
    sudo nano "$INSTALL_DIR/kalitorify"
}

remove_kalitorify() {
    echo -e "${RED}[!] Eliminando Kalitorify completamente...${RESET}"
    sudo rm -f /usr/local/bin/kalitorify
    sudo rm -rf "$INSTALL_DIR"
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
            2) activate_kalitorify ;;
            3) stop_kalitorify ;;
            4) status_kalitorify ;;
            5) flush_kalitorify ;;
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
