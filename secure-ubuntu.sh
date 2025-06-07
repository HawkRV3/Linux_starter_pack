#!/bin/bash

# Script para asegurar Ubuntu

# Verificación de root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor ejecuta como root o con sudo."
  exit
fi

echo "🔐 Comenzando la configuración de seguridad para Ubuntu..."

# 1. Activar y configurar UFW
echo "📦 Configurando UFW..."
apt update && apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw enable

# 2. Instalar y configurar Fail2ban
echo "🛡️ Instalando y configurando Fail2ban..."
apt install -y fail2ban
cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port    = 2222
logpath = %(sshd_log)s
maxretry = 5
EOF
systemctl enable fail2ban
systemctl restart fail2ban

# 3. Instalar y activar Auditd
echo "📋 Instalando Auditd..."
apt install -y auditd audispd-plugins
systemctl enable auditd
systemctl start auditd

# 4. Cambiar el puerto por defecto de SSH
NEW_SSH_PORT=2222
echo "🔧 Cambiando el puerto de SSH a $NEW_SSH_PORT..."
sed -i.bak "s/^#Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config
sed -i "s/^Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# Abrir nuevo puerto en UFW
ufw allow $NEW_SSH_PORT/tcp
ufw delete allow 22/tcp

# Reiniciar SSH
systemctl restart sshd

# 5. Activar actualizaciones automáticas
echo "🔄 Activando actualizaciones automáticas..."
apt install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades

echo "✅ Configuración de seguridad completada."
echo "Recuerda conectarte por SSH usando el puerto $NEW_SSH_PORT"
