#!/bin/bash

# Solicitar nombre del estudiante
echo "=================================="
echo "  Bienvenido a DataExplorer"
echo "=================================="
echo ""
read -p "Por favor ingrese su nombre completo: " NOMBRE_ESTUDIANTE

# Validar que el nombre no esté vacío
if [ -z "$NOMBRE_ESTUDIANTE" ]; then
    echo "❌ Error: El nombre del estudiante no puede estar vacío."
    exit 1
fi

# Mostrar mensaje de configuración personalizado
echo ""
echo "=================================="
echo "configurando ambiente DataExplorer v26.02"
echo "estudiante: $NOMBRE_ESTUDIANTE"
echo "=================================="
echo ""

# Guardar nombre del estudiante para usar luego en collect_evidence.sh
echo "$NOMBRE_ESTUDIANTE" > "$HOME/.student_name"

BASE="$HOME/dataexplorer"

# Crear estructura de carpetas
echo "📁 Creando estructura de carpetas..."
mkdir -p "$BASE/app/backend"
mkdir -p "$BASE/app/frontend/css"
mkdir -p "$BASE/app/frontend/js"
mkdir -p "$BASE/docs"
mkdir -p "$BASE/tests"
mkdir -p "$BASE/config"

# Crear archivo de configuración oculto
cat > "$BASE/.project_config" << 'EOF'
# Configuración del Proyecto DataExplorer
# ========================================
PROJECT_NAME=dataExplorer
VERSION=26.02
ENVIRONMENT=development
DEBUG=true
PORT=3000

# Configuración de Base de Datos
DB_HOST=localhost
DB_PORT=5432
DB_NAME=explorer_db
DB_USER=admin

# Rutas del Proyecto
FRONTEND_PATH=/app/frontend
BACKEND_PATH=/app/backend
STATIC_PATH=/app/frontend/assets

# No exponer claves reales en este archivo
# Las API_KEY deben estar en variables de entorno
# Usar siempre .env para secretos
EOF

# Crear environment.txt
cat > "$BASE/environment.txt" << 'EOF'
DataExplorer - Configuración de Entorno
========================================

Proyecto: Sistema de Exploración de Datos
Versión: 26.02
Autor: Equipo de Desarrollo QA
Fecha: Febrero 2026
Estado: En Desarrollo

Requisitos del Sistema:
-----------------------
- Node.js >= 16.x
- PostgreSQL >= 13
- NPM >= 8.x
- Git >= 2.x

Variables de Entorno Requeridas:
--------------------------------
- NODE_ENV=development
- PORT=3000
- DB_CONNECTION_STRING=postgresql://localhost:5432/explorer
- SESSION_SECRET=[generar con openssl]
- JWT_SECRET=[generar con openssl]
- REDIS_URL=redis://localhost:6379

Estructura de Carpetas:
-----------------------
/app
  /backend  - Lógica del servidor (Node.js/Express)
  /frontend - Interfaz de usuario (HTML/CSS/JS)
    /css    - Hojas de estilo
    /js     - Scripts del cliente
/docs       - Documentación técnica y de usuario
/tests      - Pruebas automatizadas (Jest/Mocha)
/config     - Archivos de configuración del entorno

Dependencias Principales:
-------------------------
- express: Framework web para Node.js
- postgresql: Cliente de base de datos
- dotenv: Manejo de variables de entorno
- helmet: Seguridad de headers HTTP
- cors: Control de CORS

Scripts NPM Disponibles:
------------------------
- npm start: Inicia el servidor en modo desarrollo
- npm test: Ejecuta las pruebas
- npm run build: Construye para producción
- npm run lint: Verifica estilo de código

Notas de Seguridad:
-------------------
- NUNCA commitear archivos .env al repositorio
- Usar variables de entorno para secretos
- Revisar documentación de seguridad antes de deploy
- Mantener dependencias actualizadas
- Habilitar HTTPS en producción

Contacto del Equipo:
--------------------
- Líder Técnico: tech-lead@empresa.com
- QA Manager: qa@empresa.com
- DevOps: devops@empresa.com

Última actualización: Febrero 2026
EOF

# Descargar archivos del proyecto desde GitHub
echo "📥 Descargando archivos del proyecto desde GitHub..."
GITHUB_URL="https://raw.githubusercontent.com/jmaquin0/operating_systems_2026/main/midterm1/dataexplorer_v_1_0"

# Descargar archivos HTML
wget -q "$GITHUB_URL/index.html" -O "$BASE/index.html"
wget -q "$GITHUB_URL/about.html" -O "$BASE/about.html"
wget -q "$GITHUB_URL/contact.html" -O "$BASE/contact.html"

# Descargar archivos CSS
wget -q "$GITHUB_URL/styles1.css" -O "$BASE/styles1.css"
wget -q "$GITHUB_URL/styles2.css" -O "$BASE/styles2.css"
wget -q "$GITHUB_URL/styles3.css" -O "$BASE/styles3.css"

# Descargar archivos JavaScript
wget -q "$GITHUB_URL/button_manager.js" -O "$BASE/button_manager.js"
wget -q "$GITHUB_URL/text_interaction.js" -O "$BASE/text_interaction.js"

# Descargar archivo TypeScript
wget -q "$GITHUB_URL/controller.ts" -O "$BASE/controller.ts"

# Verificar descargas exitosas
if [ $? -eq 0 ]; then
    echo "✅ Archivos descargados exitosamente"
else
    echo "⚠️  Advertencia: Algunos archivos no pudieron descargarse"
fi

echo ""
echo "✅ Estructura de carpetas creada en: $BASE"
echo "✅ Archivo oculto .project_config creado"
echo "✅ Archivo environment.txt creado"
echo "✅ Archivos del proyecto descargados desde GitHub"
echo ""
echo "Información de la sesión:"
echo "  Estudiante: $NOMBRE_ESTUDIANTE"
echo "  Directorio: $BASE"
echo ""
echo "Archivos descargados:"
ls -1 "$BASE"/*.{html,css,js,ts} 2>/dev/null | xargs -n1 basename
echo ""
echo "Para comenzar:"
echo "  cd ~/dataexplorer"
echo "  ls -la  # Para ver archivos ocultos"
echo ""
