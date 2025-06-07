# 🔐 Secure-Ubuntu Script

Este repositorio contiene un script Bash automatizado para fortalecer la seguridad básica de una instalación de Ubuntu. El objetivo es proteger el sistema desde el primer momento aplicando configuraciones recomendadas para un entorno seguro.

---

## 📜 ¿Qué hace este script?

El script `secure-ubuntu.sh` realiza los siguientes pasos:

1. **Configura el firewall (UFW):**
   - Deniega todas las conexiones entrantes por defecto.
   - Permite solo el tráfico saliente.
   - Abre el puerto SSH (se cambiará después).

2. **Instala y configura Fail2ban:**
   - Protege contra intentos de fuerza bruta en el servicio SSH.
   - Aplica una política de bloqueo temporal tras múltiples intentos fallidos.

3. **Instala y activa Auditd:**
   - Registra eventos importantes del sistema, útil para auditoría y análisis forense.

4. **Modifica la configuración de SSH:**
   - Cambia el puerto por defecto (`22`) a un puerto personalizado (`2222` por defecto).
   - Desactiva el acceso de root por SSH.
   - Desactiva la autenticación por contraseña (solo claves SSH).

5. **Activa actualizaciones automáticas:**
   - Instala y configura el paquete `unattended-upgrades` para mantener el sistema actualizado sin intervención manual.

---

## ⚙️ Requisitos

- Ubuntu 20.04, 22.04 o superior
- Acceso como usuario root o privilegios `sudo`
- Conexión a internet

---

## 🚀 Cómo usar

1. Clona el repositorio:

   ```bash
   git clone https://github.com/tu-usuario/secure-ubuntu.git
   cd secure-ubuntu
2. Da permisos de ejecución al script:
    ```bash
   chmod +x secure-ubuntu.sh

3. Ejecuta el script con sudo:
    ```bash
   sudo ./secure-ubuntu.sh

4. (Opcional) Verifica el estado de los servicios instalados:
    ```bash
    sudo systemctl status ufw
    sudo systemctl status fail2ban
    sudo systemctl status auditd
---

## ⚠️ Notas importantes

1. 🔐 Puerto SSH cambiado: El puerto SSH predeterminado se cambia a 2222
2. 🔥 UFW (Firewall): Si tienes otros servicios corriendo en el servidor, deberás permitir manualmente sus puertos con UFW
3. 🛑 Fail2ban: Las reglas están configuradas para proteger el nuevo puerto SSH. Si cambias ese puerto en el futuro, asegúrate de actualizar también
