#!/bin/bash

# Archivo de salida
EVIDENCIAS="$HOME/evidencias.txt"
BASE="$HOME/dataexplorer"

# Obtener nombre del estudiante
if [ -f "$HOME/.student_name" ]; then
    NOMBRE_ESTUDIANTE=$(cat "$HOME/.student_name")
else
    NOMBRE_ESTUDIANTE="No registrado"
fi

echo "Recopilando evidencias del proyecto DataExplorer..."
echo ""

{
    echo "========================================"
    echo "  EVIDENCIAS - EVALUACIÓN DATAEXPLORER v26.02"
    echo "========================================"
    echo ""
    echo "Estudiante: $NOMBRE_ESTUDIANTE"
    echo "Fecha y Hora: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Usuario del sistema: $(whoami)"
    echo "Hostname: $(hostname)"
    echo "Sistema Operativo: $(uname -s)"
    echo "Shell: $SHELL"
    echo "Directorio home: $HOME"
    echo ""

    echo "1. VERIFICACIÓN INICIAL"
    echo "========================"
    if [ -d "$BASE" ]; then
        echo "✅ Directorio ~/dataexplorer existe"
        echo "   Tamaño total: $(du -sh "$BASE" 2>/dev/null | cut -f1)"
    else
        echo "❌ ERROR: Directorio ~/dataexplorer NO existe"
    fi
    echo ""

    echo "2. ESTRUCTURA DE DIRECTORIOS"
    echo "=============================="
    if [ -d "$BASE" ]; then
        echo "Árbol completo de directorios:"
        if command -v tree &>/dev/null; then
            tree -L 4 "$BASE" 2>/dev/null
        else
            find "$BASE" -type d | sort | sed 's|^'"$BASE"'||; s|^|  |'
        fi
    fi
    echo ""

    echo "3. VERIFICACIÓN DE ARCHIVOS OCULTOS"
    echo "===================================="
    if [ -f "$BASE/.project_config" ]; then
        echo "✅ .project_config encontrado"
        echo "   Líneas: $(wc -l < "$BASE/.project_config")"
    else
        echo "❌ .project_config NO encontrado"
    fi

    if [ -f "$BASE/environment.txt" ]; then
        echo "✅ environment.txt encontrado"
        echo "   Líneas: $(wc -l < "$BASE/environment.txt")"
    else
        echo "❌ environment.txt NO encontrado"
    fi
    echo ""

    echo "4. VERIFICACIÓN DE ARCHIVOS DESCARGADOS"
    echo "========================================"

    # Contar archivos por tipo
    HTML_COUNT=$(find "$BASE" -maxdepth 1 -type f -name "*.html" 2>/dev/null | wc -l)
    CSS_COUNT=$(find "$BASE" -maxdepth 1 -type f -name "*.css" 2>/dev/null | wc -l)
    JS_COUNT=$(find "$BASE" -maxdepth 1 -type f -name "*.js" 2>/dev/null | wc -l)
    TS_COUNT=$(find "$BASE" -maxdepth 1 -type f -name "*.ts" 2>/dev/null | wc -l)

    echo "Archivos en raíz de dataexplorer:"
    echo "  - HTML: $HTML_COUNT archivos"
    echo "  - CSS: $CSS_COUNT archivos"
    echo "  - JavaScript: $JS_COUNT archivos"
    echo "  - TypeScript: $TS_COUNT archivos"
    echo ""

    echo "5. VERIFICACIÓN DE ORGANIZACIÓN - FRONTEND"
    echo "=========================================="

    FRONTEND_HTML=$(find "$BASE/app/frontend" -maxdepth 1 -type f -name "*.html" 2>/dev/null | wc -l)
    FRONTEND_CSS=$(find "$BASE/app/frontend/css" -type f -name "*.css" 2>/dev/null | wc -l)
    FRONTEND_JS=$(find "$BASE/app/frontend/js" -type f -name "*.js" 2>/dev/null | wc -l)

    if [ $FRONTEND_HTML -gt 0 ]; then
        echo "✅ Archivos HTML en app/frontend: $FRONTEND_HTML"
        ls -1 "$BASE/app/frontend"/*.html 2>/dev/null | xargs -n1 basename | sed 's/^/   - /'
    else
        echo "⚠️  HTML en app/frontend: 0 archivos"
    fi
    echo ""

    if [ $FRONTEND_CSS -gt 0 ]; then
        echo "✅ Archivos CSS en app/frontend/css: $FRONTEND_CSS"
        ls -1 "$BASE/app/frontend/css"/*.css 2>/dev/null | xargs -n1 basename | sed 's/^/   - /'
    else
        echo "⚠️  CSS en app/frontend/css: 0 archivos"
    fi
    echo ""

    if [ $FRONTEND_JS -gt 0 ]; then
        echo "✅ Archivos JS en app/frontend/js: $FRONTEND_JS"
        ls -1 "$BASE/app/frontend/js"/*.js 2>/dev/null | xargs -n1 basename | sed 's/^/   - /'
    else
        echo "⚠️  JS en app/frontend/js: 0 archivos"
    fi
    echo ""

    echo "6. VERIFICACIÓN DE ORGANIZACIÓN - BACKEND"
    echo "=========================================="

    BACKEND_TS=$(find "$BASE/app/backend" -type f -name "*.ts" 2>/dev/null | wc -l)

    if [ $BACKEND_TS -gt 0 ]; then
        echo "✅ Archivos TypeScript en app/backend: $BACKEND_TS"
        ls -1 "$BASE/app/backend"/*.ts 2>/dev/null | xargs -n1 basename | sed 's/^/   - /'
    else
        echo "⚠️  TypeScript en app/backend: 0 archivos"
    fi
    echo ""

    echo "7. VERIFICACIÓN DE ARCHIVOS QA"
    echo "==============================="

    if [ -d "$BASE/reports" ]; then
        echo "✅ Carpeta reports/ existe"
        REPORT_COUNT=$(find "$BASE/reports" -type f 2>/dev/null | wc -l)
        echo "   Archivos en reports: $REPORT_COUNT"

        echo ""
        if [ -f "$BASE/reports/qa_checklist.txt" ]; then
            echo "✅ qa_checklist.txt encontrado"
            echo "   Contenido:"
            cat "$BASE/reports/qa_checklist.txt" 2>/dev/null | sed 's/^/     | /'
        else
            echo "❌ qa_checklist.txt NO encontrado"
        fi

        echo ""
        if [ -f "$BASE/reports/project_log.txt" ]; then
            echo "✅ project_log.txt encontrado"
            echo "   Líneas: $(wc -l < "$BASE/reports/project_log.txt" 2>/dev/null || echo "0")"
        else
            echo "❌ project_log.txt NO encontrado"
        fi

        echo ""
        if [ -f "$BASE/reports/file_summary.txt" ]; then
            echo "✅ file_summary.txt encontrado"
            echo "   Contenido:"
            cat "$BASE/reports/file_summary.txt" 2>/dev/null | sed 's/^/     | /'
        else
            echo "❌ file_summary.txt NO encontrado"
        fi
    else
        echo "❌ Carpeta reports/ NO existe"
    fi
    echo ""

    echo "8. BÚSQUEDA DE PATRONES DE CÓDIGO"
    echo "=================================="

    FUNCTION_COUNT=$(grep -r "function" "$BASE/app/frontend/js" 2>/dev/null | wc -l)
    ADDEVENTLISTENER_COUNT=$(grep -r "addEventListener" "$BASE/app/frontend/js" 2>/dev/null | wc -l)

    echo "Funciones encontradas en JS: $FUNCTION_COUNT"
    echo "addEventListener encontrados: $ADDEVENTLISTENER_COUNT"
    echo ""

    echo "9. ANÁLISIS DE ORGANIZACIÓN"
    echo "============================"

    ERRORES=0
    ADVERTENCIAS=0

    # Verificar archivos sin organizar en la raíz
    ARCHIVOS_SIN_ORGANIZAR=$(find "$BASE" -maxdepth 1 -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | wc -l)

    if [ "$ARCHIVOS_SIN_ORGANIZAR" -eq 0 ]; then
        echo "✅ Todos los archivos de código están organizados correctamente"
    else
        echo "⚠️  Hay $ARCHIVOS_SIN_ORGANIZAR archivo(s) sin organizar en la raíz:"
        find "$BASE" -maxdepth 1 -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | sed 's/^/     - /'
        ERRORES=$((ERRORES + ARCHIVOS_SIN_ORGANIZAR))
    fi
    echo ""

    # Verificar que la estructura existe
    for DIR in app/backend app/frontend app/frontend/css app/frontend/js; do
        if [ -d "$BASE/$DIR" ]; then
            echo "✅ $DIR existe"
        else
            echo "❌ $DIR NO existe"
            ERRORES=$((ERRORES + 1))
        fi
    done
    echo ""

    echo "10. RESUMEN FINAL"
    echo "================"

    TOTAL_ARCHIVOS=$(find "$BASE" -type f ! -name ".*" 2>/dev/null | wc -l)
    TOTAL_DIRECTORIOS=$(find "$BASE" -type d 2>/dev/null | wc -l)

    echo "Estadísticas:"
    echo "  - Archivos totales: $TOTAL_ARCHIVOS"
    echo "  - Directorios totales: $TOTAL_DIRECTORIOS"
    echo "  - Errores encontrados: $ERRORES"
    echo ""

    if [ $ERRORES -eq 0 ]; then
        echo "✅ ✅ ✅ EVALUACIÓN EXITOSA ✅ ✅ ✅"
        echo "Todos los archivos están correctamente organizados"
        echo "El proyecto DataExplorer está listo para revisión"
    else
        echo "⚠️  Se encontraron $ERRORES problema(s) que requieren atención"
    fi

    echo ""
    echo "========================================"
    echo "Reporte generado: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"

} > "$EVIDENCIAS"

echo ""
echo "✅ Evidencias recopiladas exitosamente"
echo "   Archivo: $EVIDENCIAS"
echo ""
echo "Para ver las evidencias completas:"
echo "  cat ~/evidencias.txt"
echo ""
echo "Para ver solo las primeras 50 líneas:"
echo "  head -50 ~/evidencias.txt"
echo ""
