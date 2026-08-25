#!/bin/bash
# Script para configurar idioma español en WSL (Ubuntu/Debian)

echo "🔧 Configurando idioma a Español..."

# Actualizar repositorios
sudo apt update

# Instalar paquetes de idioma
sudo apt install -y language-pack-es locales

# Generar locales en español
sudo locale-gen es_ES.UTF-8
sudo update-locale LANG=es_ES.UTF-8 LANGUAGE=es_ES:es LC_ALL=es_ES.UTF-8

# Exportar variables en el perfil del usuario
echo 'export LANG=es_ES.UTF-8' >> ~/.bashrc
echo 'export LANGUAGE=es_ES:es' >> ~/.bashrc
echo 'export LC_ALL=es_ES.UTF-8' >> ~/.bashrc

# Recargar configuración
source ~/.bashrc

echo "✅ Idioma configurado a Español. Reinicia tu terminal para aplicar cambios."
