#!/usr/bin/env bash
#
# ============================================================================
#  iniciar-taller5.sh
#
#  Reconstruye el resultado final del "Taller práctico semana 4"
#  (comandos mkdir, touch, wget, cp y mv) para que los estudiantes que
#  no lo hayan terminado puedan iniciar el "Taller práctico semana 5"
#  (cat, head, tail, redirecciones, tuberías y grep).
#
#  Uso:
#      bash iniciar-taller5.sh
#
#  El script crea la carpeta ~/taller-terminal en el estado exacto que
#  el taller 5 da por hecho:
#
#    taller-terminal/
#    ├── registro.log                 (vacío)
#    ├── inventario.csv               (vacío)
#    ├── descargas/textos/            pg2000.txt, pg2701.txt, .gitkeep
#    ├── copias/
#    │   ├── quijote.txt  alicia-copia.txt  poe.txt
#    │   ├── respaldo-anual/          (respaldo-2026 renombrado, 5 textos)
#    │   └── textos-respaldo/         (copia recursiva de descargas/textos)
#    ├── organizados/
#    │   ├── notas.txt                (vacío, movido desde la raíz)
#    │   ├── quijote/don-quijote-1605.txt
#    │   ├── alicia/alicia.txt  alicia/poe-relatos.txt
#    │   └── poe/                     (queda vacía)
#    └── archivo-final/
#        └── 2026-don-quijote-1605.txt  2026-alicia.txt  2026-poe-relatos.txt
#
#  Requisitos: conexión a internet y wget instalado.
#  No requiere permisos de administrador: todo ocurre dentro del home.
# ============================================================================

set -u  # tratar variables no definidas como error

# ----------------------------------------------------------------------------
# 0. Comprobaciones iniciales (equivalen a la sección "Comprobaciones
#    iniciales" del taller 4)
# ----------------------------------------------------------------------------

echo "=== Preparación del entorno para el Taller práctico semana 5 ==="
echo
echo "Usuario  : $(whoami)"
echo "Carpeta  : $(pwd)"
echo

if ! command -v wget > /dev/null 2>&1; then
    echo "ERROR: wget no está instalado." >&2
    echo "Instálelo antes de continuar:" >&2
    echo "  sudo apt update && sudo apt install wget   # Debian, Ubuntu, WSL" >&2
    echo "  brew install wget                          # macOS con Homebrew" >&2
    exit 1
fi

TALLER="$HOME/taller-terminal"

# Si ya existe una carpeta del taller anterior, se aparta con otro nombre
# en lugar de borrarla, para no destruir trabajo previo del estudiante.
if [ -e "$TALLER" ]; then
    RESPALDO="$HOME/taller-terminal.anterior.$(date +%Y%m%d-%H%M%S)"
    mv "$TALLER" "$RESPALDO"
    echo "AVISO: ya existía ~/taller-terminal."
    echo "       Se guardó una copia de seguridad en: $RESPALDO"
    echo
fi

# ----------------------------------------------------------------------------
# 1. Parte 1 del taller 4: estructura de directorios y archivos vacíos
# ----------------------------------------------------------------------------

echo "[1/5] Creando la estructura de directorios (mkdir -p)..."

cd "$HOME"
mkdir taller-terminal
cd "$TALLER"

mkdir -p descargas/textos
mkdir -p copias/respaldo-2026
mkdir -p organizados/quijote organizados/alicia organizados/poe

# Archivos vacíos creados con touch (1.4)
touch notas.txt
touch registro.log inventario.csv
touch descargas/textos/.gitkeep

# ----------------------------------------------------------------------------
# 2. Parte 2 del taller 4: descarga de los textos del Proyecto Gutenberg
# ----------------------------------------------------------------------------

echo "[2/5] Descargando los textos del Proyecto Gutenberg (wget)..."

URL_QUIJOTE="https://www.gutenberg.org/cache/epub/2000/pg2000.txt"
URL_ALICIA="https://www.gutenberg.org/cache/epub/11/pg11.txt"
URL_POE="https://www.gutenberg.org/cache/epub/2148/pg2148.txt"
URL_MOBY="https://www.gutenberg.org/cache/epub/2701/pg2701.txt"

cd "$TALLER/descargas/textos"

# descarga_verificada URL destino  →  descarga y comprueba que no quedó vacío
descarga_verificada() {
    local url="$1" destino="$2"
    wget -q -O "$destino" "$url"
    if [ ! -s "$destino" ]; then
        echo "ERROR: la descarga de $destino falló (archivo vacío)." >&2
        echo "       Revise su conexión a internet y vuelva a ejecutar el script." >&2
        exit 1
    fi
    echo "  - $destino descargado ($(du -h "$destino" | cut -f1))"
}

descarga_verificada "$URL_QUIJOTE" "pg2000.txt"       # 2.1 nombre original
descarga_verificada "$URL_ALICIA"  "alicia.txt"       # 2.2 wget -O
descarga_verificada "$URL_POE"     "poe.txt"          # 2.2 wget -O
descarga_verificada "$URL_MOBY"    "pg2701.txt"       # 2.3 wget -P

# quijote.txt es el mismo texto que pg2000.txt: se copia en lugar de
# descargarlo dos veces (2.2 del taller lo bajaba de nuevo con wget -O).
cp pg2000.txt quijote.txt
echo "  - quijote.txt creado a partir de pg2000.txt"

# ----------------------------------------------------------------------------
# 3. Parte 3.1 y 3.2 del taller 4: copias con cp
# ----------------------------------------------------------------------------

echo "[3/5] Realizando las copias (cp)..."

cd "$TALLER"

cp descargas/textos/quijote.txt copias/                       # 3.1
cp descargas/textos/alicia.txt  copias/alicia-copia.txt       # 3.1
cp descargas/textos/*.txt       copias/respaldo-2026/         # 3.1 (varios)
cp -r descargas/textos          copias/textos-respaldo        # 3.2 (cp -r)
cp descargas/textos/poe.txt     copias/                       # 3.2 (cp -iv)

# ----------------------------------------------------------------------------
# 4. Parte 3.3 y 3.4 del taller 4: mover y renombrar con mv
# ----------------------------------------------------------------------------

echo "[4/5] Moviendo y renombrando (mv)..."

cd "$TALLER"

# 3.3 mover los tres textos a organizados/
mv descargas/textos/quijote.txt organizados/quijote/
mv descargas/textos/alicia.txt  organizados/alicia/
mv descargas/textos/poe.txt     organizados/poe/

# 3.4 renombrar archivo, renombrar directorio, mover+renombrar, mover notas
mv organizados/quijote/quijote.txt organizados/quijote/don-quijote-1605.txt
mv copias/respaldo-2026            copias/respaldo-anual
mv organizados/poe/poe.txt         organizados/alicia/poe-relatos.txt
mv notas.txt                       organizados/notas.txt

# Ejercicio de la Parte 3: archivo-final con copias prefijadas 2026-
mkdir -p archivo-final
cp organizados/quijote/don-quijote-1605.txt archivo-final/2026-don-quijote-1605.txt
cp organizados/alicia/alicia.txt            archivo-final/2026-alicia.txt
cp organizados/alicia/poe-relatos.txt       archivo-final/2026-poe-relatos.txt

# ----------------------------------------------------------------------------
# 5. Verificación final (sección "Cierre y entrega" del taller 4)
# ----------------------------------------------------------------------------

echo "[5/5] Verificando el resultado..."
echo

ERRORES=0

verificar() {
    # verificar tipo ruta   (tipo: f = archivo con contenido, e = existe, d = directorio)
    local tipo="$1" ruta="$2"
    local ok=1
    case "$tipo" in
        f) [ -s "$TALLER/$ruta" ] && ok=0 ;;
        e) [ -e "$TALLER/$ruta" ] && ok=0 ;;
        d) [ -d "$TALLER/$ruta" ] && ok=0 ;;
    esac
    if [ "$ok" -eq 0 ]; then
        echo "  [OK]    $ruta"
    else
        echo "  [FALTA] $ruta"
        ERRORES=$((ERRORES + 1))
    fi
}

verificar d "descargas/textos"
verificar f "descargas/textos/pg2000.txt"
verificar f "descargas/textos/pg2701.txt"
verificar e "descargas/textos/.gitkeep"
verificar f "organizados/quijote/don-quijote-1605.txt"
verificar f "organizados/alicia/alicia.txt"
verificar f "organizados/alicia/poe-relatos.txt"
verificar d "organizados/poe"
verificar e "organizados/notas.txt"
verificar f "copias/quijote.txt"
verificar f "copias/alicia-copia.txt"
verificar f "copias/poe.txt"
verificar d "copias/respaldo-anual"
verificar d "copias/textos-respaldo"
verificar f "archivo-final/2026-don-quijote-1605.txt"
verificar f "archivo-final/2026-alicia.txt"
verificar f "archivo-final/2026-poe-relatos.txt"
verificar e "registro.log"
verificar e "inventario.csv"

echo
if [ "$ERRORES" -eq 0 ]; then
    echo "=== Todo listo. El espacio de trabajo quedó en el estado final del taller 4. ==="
    echo
    echo "Puede comprobarlo usted mismo con:"
    echo "    ls -R ~/taller-terminal"
    echo
    echo "Ya puede comenzar el Taller práctico semana 5:"
    echo "    cd ~/taller-terminal"
else
    echo "=== ATENCIÓN: faltan $ERRORES elementos. Revise los mensajes anteriores ===" >&2
    echo "=== y vuelva a ejecutar el script. ===" >&2
    exit 1
fi


