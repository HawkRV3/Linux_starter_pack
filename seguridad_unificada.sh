#!/bin/bash

# 🔐 Script Unificado de Seguridad, Monitoreo y Anonimato (Ubuntu)
# Autor: Ian & Jonhatan
# Versión: 3.2 - 2025-07-06

# ==== Configuración ====
NEW_SSH_PORT=2222
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_BACKUP="/etc/ssh/sshd_config.bak"
LOGFILE="/var/log/secure-ubuntu.log"
MONITOR_DIR="/opt/monitoring_tools"
REPO_URL="https://github.com/brainfucksec/kalitorify.git"
KALI_DIR="./kalitorify"

# ==== Colores ====
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# ==== Funciones generales ====
log() {
  echo -e "${YELLOW}$(date '+%F %T') - $1${RESET}" | tee -a "$LOGFILE"
}

pause() {
  echo -e "\nPresiona [ENTER] para continuar..."
  read
}

banner() {
    echo -e "${CYAN}"
    echo "============================================"
    echo "    🔐 HARDENING + MONITOREO + KALITORIFY   "
    echo "============================================"
    echo -e "${RESET}"
}

# ==== Funciones de Kalitorify ====
install_kalitorify() {
    log "🧩 Instalando Kalitorify..."
    git clone "$REPO_URL" || { log "❌ Error al clonar el repositorio Kalitorify."; return 1; }
    apt-get update && apt-get dist-upgrade -y
    apt-get install -y tor curl make
    cd "$KALI_DIR" || { log "❌ No se pudo entrar al directorio $KALI_DIR."; return 1; }
    make install
    command -v kalitorify &> /dev/null && log "✅ Kalitorify instalado correctamente." || log "❌ Kalitorify no se encuentra en el PATH."
}

remove_kalitorify() {
    log "🗑 Eliminando Kalitorify..."
    if [ -d "$KALI_DIR" ]; then
        make -C "$KALI_DIR" uninstall
        rm -rf "$KALI_DIR"
    else
        rm -rf /usr/bin/kalitorify /usr/share/kalitorify /usr/share/doc/kalitorify /var/lib/kalitorify
    fi
    log "✅ Kalitorify eliminado correctamente."
}

# ==== Hardening ====
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

  log "✅ Endurecimiento completado."
}

revert_hardening() {
  log "🔓 Revirtiendo configuración de hardening..."
  [ -f "$SSHD_BACKUP" ] && cp "$SSHD_BACKUP" "$SSHD_CONFIG"
  ufw reset && ufw enable && ufw allow 22/tcp
  apt remove --purge -y fail2ban auditd audispd-plugins unattended-upgrades flatpak
  apt autoremove -y
  systemctl restart sshd
  log "✅ Hardening revertido."
}

# ==== Monitoreo ====
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
echo "Uso: $(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "%"}')"
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
  log "✅ Monitoreo instalado en $MONITOR_DIR"
}

uninstall_monitoring_tools() {
  log "🗑 Desinstalando herramientas de monitoreo..."
  apt remove -y htop nvtop sysstat lm-sensors nvidia-smi
  crontab -l | grep -v "$MONITOR_DIR/system_monitor.sh" | crontab -
  rm -rf "$MONITOR_DIR"
  sed -i '/gpustat/d' /etc/bash.bashrc
  log "✅ Monitoreo eliminado."
}

# ==== Instalación total ====
install_all() {
  basic_hardening
  install_monitoring_tools
  install_kalitorify
  log "✅ Instalación completa realizada."
}

# ==== Reversión total ====
revert_all() {
  log "♻ Revirtiendo todos los cambios..."
  revert_hardening
  uninstall_monitoring_tools
  remove_kalitorify
  log "✅ Sistema revertido completamente."
}

# ==== Menú ====
main_menu() {
  while true; do
    clear
    banner
    echo "1) 🛡 Endurecimiento del sistema"
    echo "2) Deshacer endurecimiento del sistema"
    echo "3) 📊 Instalar herramientas de monitoreo"
    echo "4) 🗑 Eliminar herramientas de monitoreo"
    echo "5) 🔍 Instalar Kalitorify"
    echo "6) ❌ Eliminar Kalitorify"
    echo "7) ⚙ Instalar TODO (hardening + monitoreo + kalitorify)"
    echo "8) ♻ Revertir TODO"
    echo "9) Salir"
    echo -n -e "\nSelecciona una opción: "
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
      9) log "Saliendo..."; exit 0 ;;
      *) echo -e "${RED}Opción inválida.${RESET}" ;;
    esac
    pause
  done
}

# ==== Verificación de root ====
[ "$EUID" -ne 0 ] && echo -e "${RED}❌ Ejecuta como root.${RESET}" && exit 1

# ==== Lanzar menú ====
main_menu
