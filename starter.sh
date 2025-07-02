#!/bin/bash

# Script de endurecimiento y monitoreo básico de Ubuntu
# Autor: Jonhatan
# Versión: 2.1 

# Configuración
NEW_SSH_PORT=2222
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_BACKUP="/etc/ssh/sshd_config.bak"
LOGFILE="/var/log/secure-ubuntu.log"
MONITOR_DIR="/opt/monitoring_tools"

log() {
  echo "$(date '+%F %T') - $1" | tee -a "$LOGFILE"
}

install_monitoring_tools() {
  log "📊 Instalando herramientas de monitoreo básico..."
  
  # Crear directorio para herramientas
  mkdir -p "$MONITOR_DIR"
  
  # Herramientas básicas del sistema
  apt install -y htop nvtop sysstat lm-sensors
  
  # Detectar e instalar herramientas NVIDIA si existe GPU
  if lspci | grep -i nvidia; then
    log "🖥 Detectada GPU NVIDIA, instalando herramientas..."
    apt install -y nvidia-smi
    echo "alias gpustat='nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used,temperature.gpu --format=csv'" >> /etc/bash.bashrc
  fi
  
  # Script de monitoreo personalizado
  cat > "$MONITOR_DIR/system_monitor.sh" <<'EOF'
#!/bin/bash
echo "=== MONITOREO DEL SISTEMA ==="
echo "Fecha: $(date)"
echo "Uptime: $(uptime)"

echo -e "\n=== CPU ==="
echo "Uso: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')%"
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
  
  # Agregar a cron para monitoreo periódico
  (crontab -l 2>/dev/null; echo "*/10 * * * * $MONITOR_DIR/system_monitor.sh >> $MONITOR_DIR/monitor.log") | crontab -
  
  log "✅ Monitoreo básico instalado en $MONITOR_DIR"
  log "ℹ Comandos útiles: htop, nvtop, gpustat (para NVIDIA)"
}

uninstall_monitoring_tools() {
  log "🔄 Desinstalando herramientas de monitoreo..."
  
  # Desinstalar paquetes
  apt remove -y htop nvtop sysstat lm-sensors nvidia-smi
  
  # Eliminar entradas de cron
  crontab -l | grep -v "$MONITOR_DIR/system_monitor.sh" | crontab -
  
  # Eliminar directorio
  rm -rf "$MONITOR_DIR"
  
  # Eliminar alias
  sed -i '/gpustat/d' /etc/bash.bashrc
  
  log "✅ Herramientas de monitoreo desinstaladas"
}

revert_menu() {
  while true; do
    clear
    echo "🔁 MENÚ DE REVERSIÓN"
    echo "1) Restaurar configuración SSH"
    echo "2) Revertir reglas UFW"
    echo "3) Desinstalar Fail2ban"
    echo "4) Desinstalar Auditd"
    echo "5) Desinstalar Flatpak"
    echo "6) Desinstalar herramientas de monitoreo"
    echo "7) Revertir TODO"
    echo "8) Volver al menú principal"
    read -rp "Selecciona una opción [1-8]: " OPTION

    case $OPTION in
      1)
        log "Restaurando configuración SSH..."
        [ -f "$SSHD_BACKUP" ] && cp "$SSHD_BACKUP" "$SSHD_CONFIG" && systemctl restart sshd
        ;;
      2)
        log "Revirtiendo reglas UFW..."
        ufw reset && ufw enable && ufw allow 22/tcp
        ;;
      3)
        log "Desinstalando Fail2ban..."
        apt remove --purge -y fail2ban && rm -f /etc/fail2ban/jail.local
        ;;
      4)
        log "Desinstalando Auditd..."
        apt remove --purge -y auditd audispd-plugins
        ;;
      5)
        log "Desinstalando Flatpak..."
        apt remove --purge -y flatpak
        ;;
      6)
        uninstall_monitoring_tools
        ;;
      7)
        revert_all
        ;;
      8)
        return
        ;;
      *)
        log "Opción inválida."
        ;;
    esac
    
    read -rp "Presiona Enter para continuar..."
  done
}

revert_all() {
  log "♻ Revirtiendo todos los cambios..."
  [ -f "$SSHD_BACKUP" ] && cp "$SSHD_BACKUP" "$SSHD_CONFIG"
  ufw reset && ufw enable && ufw allow 22/tcp
  apt remove --purge -y fail2ban auditd audispd-plugins unattended-upgrades flatpak
  uninstall_monitoring_tools
  apt autoremove -y
  systemctl restart sshd
  log "✅ Todos los cambios revertidos"
  exit 0
}

basic_hardening() {
  # 1. Actualización inicial
  apt update && apt upgrade -y
  
  # 2. UFW
  log "📦 Configurando UFW..."
  apt install -y ufw
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow "$NEW_SSH_PORT/tcp"
  ufw --force enable

  # 3. Fail2ban
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

  # 4. SSH
  log "🔧 Configurando SSH..."
  cp "$SSHD_CONFIG" "$SSHD_BACKUP"
  sed -i "s/^#\?Port .*/Port $NEW_SSH_PORT/" "$SSHD_CONFIG"
  sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" "$SSHD_CONFIG"
  sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" "$SSHD_CONFIG"
  systemctl restart sshd

  # 5. Actualizaciones automáticas
  log "🔄 Configurando actualizaciones automáticas..."
  apt install -y unattended-upgrades
  dpkg-reconfigure -f noninteractive unattended-upgrades

  # 6. Auditd
  log "📋 Instalando Auditd..."
  apt install -y auditd audispd-plugins
  systemctl enable --now auditd

  log "✅ Endurecimiento básico completado"
}

main_menu() {
  while true; do
    clear
    echo "🔐 MENÚ PRINCIPAL - HARDENING Y MONITOREO BÁSICO"
    echo "1) Endurecimiento básico del sistema"
    echo "2) Instalar herramientas de monitoreo básico"
    echo "3) Revertir cambios"
    echo "4) Salir"
    read -rp "Selecciona una opción [1-4]: " OPTION

    case $OPTION in
      1)
        basic_hardening
        ;;
      2)
        install_monitoring_tools
        ;;
      3)
        revert_menu
        ;;
      4)
        log "Saliendo del script"
        exit 0
        ;;
      *)
        log "Opción inválida"
        ;;
    esac
    
    read -rp "Presiona Enter para continuar..."
  done
}

# Verificación de root
[ "$EUID" -ne 0 ] && echo "❌ Ejecuta como root" && exit 1

# Manejo de argumentos
case "$1" in
  "--revert") revert_menu ;;
  "--revert-all") revert_all ;;
  "--monitoring") install_monitoring_tools ;;
  *) main_menu ;;
esac
