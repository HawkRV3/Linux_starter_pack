# 🔐 Starter Pack: Seguridad, Monitoreo y Anonimato para Ubuntu

Autor: **PT&A**  
Versión: **1.0 - 2025-07-06**

---

## 📦 Descripción General

**starter_pack** es un script interactivo diseñado para sistemas **Ubuntu** que automatiza tres funciones esenciales:

1. **Endurecimiento (Hardening)** del sistema para reforzar la seguridad.
2. **Instalación de herramientas de monitoreo** para supervisar el rendimiento de hardware.
3. **Implementación de Kalitorify**, una herramienta de anonimato que enruta el tráfico por la red TOR.

> Ideal para entornos personales, laboratorios de ciberseguridad, profesionales de IT y usuarios nuevos.

---

## 🧰 Funcionalidades Detalladas

### 1. 🛡 Endurecimiento del sistema
Este módulo implementa medidas básicas de seguridad:
- **Cambia el puerto SSH** a `2222` y desactiva el login por contraseña y acceso root.
- **Activa el firewall UFW** con reglas restrictivas.
- **Instala Fail2ban** para bloquear intentos de fuerza bruta por SSH.
- **Habilita actualizaciones automáticas** con `unattended-upgrades`.
- **Instala Auditd** para auditar actividades del sistema.

> Puede revertirse automáticamente desde el menú.

---

### 2. 📊 Herramientas de Monitoreo
Instala utilidades para monitorear recursos del sistema:
- `htop`, `nvtop`: Monitorización de CPU y GPU.
- `sysstat`, `lm-sensors`: Estadísticas de sistema y sensores térmicos.
- `nvidia-smi` (si se detecta GPU NVIDIA).
- Script personalizado que guarda cada 10 minutos la información de CPU, RAM, discos, sensores y GPU en `/opt/monitoring_tools/monitor.log`.

> También se crea un alias `gpustat` en `/etc/bash.bashrc` para ver el estado de la GPU fácilmente.

---

### 3. 🔍 Kalitorify
Instala [Kalitorify](https://github.com/brainfucksec/kalitorify), un proxy transparente que enruta todo el tráfico por la red TOR, permitiendo un alto nivel de anonimato en la navegación.

Incluye:
- Clonación y compilación del repositorio.
- Dependencias necesarias (`tor`, `curl`, `make`).
- Verificación de instalación en el sistema.

> Elimina todos los componentes con una opción del menú.

---

### 4. 📚 Instalación de `tldr`
Se instala la herramienta `tldr`, que ofrece páginas de ayuda simplificadas y ejemplos para comandos comunes.

**Manual rápido:**
- Ejecuta `tldr <comando>` para ver un resumen amigable de cómo usar un comando.  
  Ejemplo: `tldr tar`

---

### 5. ⚙ Instalación/Reversión Total
- Puedes aplicar todas las configuraciones de seguridad, monitoreo y anonimato con una sola opción.
- También puedes **revertir todos los cambios** con otro comando si algo falla o ya no lo necesitas.

---

## ▶️ Cómo Usarlo

### 🔒 Requisitos
- Distribución basada en **Ubuntu**.
- Ejecutar como **root** (o con `sudo`).

### 💻 Ejecución
```bash
chmod +x starter_pack.sh
sudo ./starter_pack.sh
```

### 🧭 Menú Interactivo
```
1) Endurecimiento del sistema
2) Deshacer endurecimiento del sistema
3) Instalar herramientas de monitoreo
4) Eliminar herramientas de monitoreo
5) Instalar Kalitorify
6) Eliminar Kalitorify
7) Instalar TODO (hardening + monitoreo + kalitorify)
8) Revertir TODO
9) Salir
```

---

## 🔗 Repositorios Oficiales de Herramientas

- **Kalitorify**  
  https://github.com/brainfucksec/kalitorify

- **Fail2ban**  
  https://github.com/fail2ban/fail2ban

- **UFW (Uncomplicated Firewall)**  
  https://wiki.ubuntu.com/UncomplicatedFirewall

- **Auditd**  
  https://github.com/linux-audit/audit-userspace

- **htop**  
  https://github.com/htop-dev/htop

- **nvtop**  
  https://github.com/Syllo/nvtop

- **sysstat**  
  https://github.com/sysstat/sysstat

- **lm-sensors**  
  https://github.com/lm-sensors/lm-sensors

- **unattended-upgrades**  
  https://wiki.debian.org/UnattendedUpgrades

- **nvidia-smi**  
  https://developer.nvidia.com/nvidia-system-management-interface

- **tldr**
  https://github.com/tldr-pages/tldr

---

## ⚠️ Disclaimer

> **Este script se proporciona con fines educativos y de automatización para administradores y usuarios primerizos.**
>
> - El uso indebido de herramientas como Kalitorify podría violar términos de uso de algunas redes.
> - No nos hacemos responsables por daños, pérdidas o problemas de conectividad derivados del uso de este script.
> - **Recomendamos probarlo en un entorno virtualizado antes de aplicarlo en sistemas de producción.**

---
