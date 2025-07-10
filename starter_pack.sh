#!/bin/bash

# 🔐 Script Unificado de Seguridad, Monitoreo y Anonimato (Ubuntu)
# Autor: PT&A
# Versión: 1.0 - 2025-07-06

# ==== Configuración ====
NEW_SSH_PORT=2222
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_BACKUP="/etc/ssh/sshd_config.bak"
LOGFILE="/var/log/secure-ubuntu.log"
MONITOR_DIR="/opt/monitoring_tools"
REPO_URL="https://github.com/brainfucksec/kalitorify.git"
KALI_DIR="./kalitorify"

# ==== Colores (compatibles con tput) ====
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# ==== Funciones generales ====
log() {
  local msg="$1"
  local color="$2"
  local time=$(date '+%F %T')
  case $color in
    "success") echo -e "${GREEN}${time} - ${msg}${RESET}" | tee -a "$LOGFILE" ;;
    "error") echo -e "${RED}${time} - ${msg}${RESET}" | tee -a "$LOGFILE" ;;
    *) echo -e "${YELLOW}${time} - ${msg}${RESET}" | tee -a "$LOGFILE" ;;
  esac
}

pause() {
  echo -e "\nPresiona [ENTER] para continuar..."
  read
}

banner() {
    echo -e "${CYAN}"
    cat <<'EOF'
          /~~~~~~\
        /'    -s- ~~~~\
       /'dHHb      ~~~~
      /'dHHHA     :
     /' VHHHHaadHHb:
    /'   `VHHHHHHHHb:
   /'      `VHHHHHHH:
  /'        dHHHHHHH:
  |        dHHHHHHHH:
  |       dHHHHHHHH:
  |       VHHHHHHHHH:
  |   b    HHHHHHHHV:
  |   Hb   HHHHHHHV'
  |   HH  dHHHHHHV'
  |   VHbdHHHHHHV'
  |    VHHHHHHHV'
   \    VHHHHHHH:
    \oodboooooodH
EOF
    echo -e "${RESET}"
    echo -e "${GREEN}                PT&A${RESET}"
    echo -e "${CYAN}         PenguinVault v1.0${RESET}"
    echo -e "${CYAN}=============================================${RESET}"
}



install_kalitorify() {
  log "🧩 Instalando Kalitorify..."
  git clone "$REPO_URL" || { log "❌ Error al clonar el repositorio Kalitorify." error; return 1; }
  apt-get update && apt-get dist-upgrade -y
  apt-get install -y tor curl make
  cd "$KALI_DIR" || { log "❌ No se pudo entrar al directorio $KALI_DIR." error; return 1; }
  make install
  command -v kalitorify &> /dev/null && log "✅ Kalitorify instalado correctamente." success || log "❌ Kalitorify no se encuentra en el PATH." error
}

remove_kalitorify() {
  log "🗑 Eliminando Kalitorify..."
  if [ -d "$KALI_DIR" ]; then
    make -C "$KALI_DIR" uninstall
    rm -rf "$KALI_DIR"
  else
    rm -rf /usr/bin/kalitorify /usr/share/kalitorify /usr/share/doc/kalitorify /var/lib/kalitorify
  fi
  log "✅ Kalitorify eliminado correctamente." success
}

basic_hardening() {
  apt update && apt upgrade -y
  log "🔐 Configurando UFW..."
  apt install -y ufw
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow "$NEW_SSH_PORT/tcp"
  ufw --force enable

  log "🛡 Instalando Fail2ban..."
  apt install -y fail2ban
  cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = $NEW_SSH_PORT
logpath = %(sshd_log)s
maxretry = 5
EOF
  systemctl restart fail2ban

  log "🔧 Configurando SSH..."
  cp "$SSHD_CONFIG" "$SSHD_BACKUP"
  sed -i "s/^#\?Port .*/Port $NEW_SSH_PORT/" "$SSHD_CONFIG"
  sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" "$SSHD_CONFIG"
  sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" "$SSHD_CONFIG"
  systemctl restart sshd

  log "🔄 Configurando actualizaciones automáticas..."
  apt install -y unattended-upgrades
  dpkg-reconfigure -f noninteractive unattended-upgrades

  log "📋 Instalando Auditd..."
  apt install -y auditd audispd-plugins
  systemctl enable --now auditd

  log "✅ Endurecimiento completado." success
}

revert_hardening() {
  log "🔓 Revirtiendo configuración de hardening..."
  [ -f "$SSHD_BACKUP" ] && cp "$SSHD_BACKUP" "$SSHD_CONFIG"
  ufw reset && ufw enable && ufw allow 22/tcp
  apt remove --purge -y fail2ban auditd audispd-plugins unattended-upgrades flatpak
  apt autoremove -y
  systemctl restart sshd
  log "✅ Hardening revertido." success
}

install_monitoring_tools() {
  log "📊 Instalando herramientas de monitoreo..."
  mkdir -p "$MONITOR_DIR"
  apt install -y htop nvtop sysstat lm-sensors
  if lspci | grep -i nvidia; then
    log "🖥 Detectada GPU NVIDIA, instalando herramientas..."
    apt install -y nvidia-smi
    echo "alias gpustat='nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used,temperature.gpu --format=csv'" >> /etc/bash.bashrc
  fi
  cat > "$MONITOR_DIR/system_monitor.sh" <<'EOF'
#!/bin/bash
echo "=== MONITOREO DEL SISTEMA ==="
echo "Fecha: $(date)"
echo "Uptime: $(uptime)"
echo -e "\n=== CPU ==="
echo "Uso: $(top -bn1 | grep \"Cpu(s)\" | awk '{print 100 - $8 "%"}')"
sensors | grep 'Package id' | awk '{print "Temperatura: " $4}'
if command -v nvidia-smi &> /dev/null; then
  echo -e "\n=== GPU NVIDIA ==="
  nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader
fi
echo -e "\n=== MEMORIA ==="
free -h
echo -e "\n=== DISCOS ==="
df -h
EOF
  chmod +x "$MONITOR_DIR/system_monitor.sh"
  (crontab -l 2>/dev/null; echo "*/10 * * * * $MONITOR_DIR/system_monitor.sh >> $MONITOR_DIR/monitor.log") | crontab -
  log "✅ Monitoreo instalado en $MONITOR_DIR" success
}

uninstall_monitoring_tools() {
  log "🗑 Desinstalando herramientas de monitoreo..."
  apt remove -y htop nvtop sysstat lm-sensors nvidia-smi
  crontab -l | grep -v "$MONITOR_DIR/system_monitor.sh" | crontab -
  rm -rf "$MONITOR_DIR"
  sed -i '/gpustat/d' /etc/bash.bashrc
  log "✅ Monitoreo eliminado." success
}

install_all() {
  basic_hardening
  install_monitoring_tools
  install_kalitorify
  log "✅ Instalación completa realizada." success
}

revert_all() {
  log "♻ Revirtiendo todos los cambios..."
  revert_hardening
  uninstall_monitoring_tools
  remove_kalitorify
  log "✅ Sistema revertido completamente." success
}

main_menu() {
  while true; do
    clear
    banner
    echo -e "${GREEN}1)${RESET} 🛡 ${CYAN}Endurecimiento del sistema${RESET}"
    echo -e "${GREEN}2)${RESET} 🔓 ${CYAN}Deshacer endurecimiento del sistema${RESET}"
    echo -e "${GREEN}3)${RESET} 📊 ${CYAN}Instalar herramientas de monitoreo${RESET}"
    echo -e "${GREEN}4)${RESET} 🗑 ${CYAN}Eliminar herramientas de monitoreo${RESET}"
    echo -e "${GREEN}5)${RESET} 🔍 ${CYAN}Instalar Kalitorify${RESET}"
    echo -e "${GREEN}6)${RESET} ❌ ${CYAN}Eliminar Kalitorify${RESET}"
    echo -e "${GREEN}7)${RESET} ⚙ ${CYAN}Instalar TODO (hardening + monitoreo + kalitorify)${RESET}"
    echo -e "${GREEN}8)${RESET} ♻ ${CYAN}Revertir TODO${RESET}"
    echo -e "${GREEN}9)${RESET} 🚪 ${CYAN}Salir${RESET}"
    echo -e "\n${CYAN}----------------------------------------${RESET}\n"
    echo -n -e "Selecciona una opción: "
    read -r option
    case $option in
      1) basic_hardening ;;
      2) revert_hardening ;;
      3) install_monitoring_tools ;;
      4) uninstall_monitoring_tools ;;
      5) install_kalitorify ;;
      6) remove_kalitorify ;;
      7) install_all ;;
      8) revert_all ;;
      9) log "Saliendo..." success; exit 0 ;;
      *) echo -e "${RED}Opción inválida.${RESET}" ;;
    esac
    pause
  done
}

[ "$EUID" -ne 0 ] && echo -e "${RED}❌ Ejecuta como root.${RESET}" && exit 1

main_menu
