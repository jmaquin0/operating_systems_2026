#!/bin/bash
# =====================================================================
#  Evaluación práctica A - LogiTrans / RutaFácil
#  Ubuntu (WSL2 o Multipass).  Uso:   source setup_parcial_A.sh
#  (también funciona con:  bash setup_parcial_A.sh)
#  Este script SOLO puede ejecutarse una vez.
# =====================================================================

_setup_parcial_A() {
    local codigo nombre me migrupo base

    if [ "$(id -u)" -eq 0 ]; then
        echo "ERROR: no ejecute este script como root. Use su cuenta normal (con sudo)."
        return 1
    fi
    if ! sudo -n true 2>/dev/null && ! sudo -v; then
        echo "ERROR: su cuenta necesita permisos de sudo."
        return 1
    fi

    echo "Por favor, introduce tu código de estudiante:"
    read -r codigo
    if ! [[ "$codigo" =~ ^[0-9]{3,}$ ]]; then
        echo "ERROR: el código debe ser numérico y tener al menos 3 dígitos."
        return 1
    fi
    echo "Por favor, introduce tu nombre completo:"
    read -r nombre
    if [ -z "$nombre" ]; then
        echo "ERROR: el nombre no puede estar vacío."
        return 1
    fi

    echo "Configurando ambiente para: $nombre, Código: $codigo"
    echo "Fecha del sistema: $(date '+%F %T')   Cuenta: $(id -un)"
    echo "==================================================="
    echo "============== ADVERTENCIA ! ======================"
    echo "==================================================="
    echo "Este script solamente puede ejecutarse una vez     "
    echo "(crea /opt/rutafacil y archivos del sistema).      "
    echo "==================================================="

    me="$(id -un)"
    migrupo="$(id -gn)"
    base=/opt/rutafacil

    if [ -e "$base" ]; then
        echo "ERROR: $base ya existe. El ambiente ya fue creado anteriormente."
        return 1
    fi

    # ---- Estructura de la aplicación (propiedad de la cuenta actual) ----
    sudo install -d -m 755 -o "$me" -g "$migrupo" "$base" || return 1
    mkdir -p "$base"/data "$base"/frontend "$base"/backend "$base"/tools || return 1

    cat > "$base/data/rutas_2025.csv" <<'EOF'
id_ruta,origen,destino,km
R001,Cali,Bogota,462
R002,Cali,Medellin,420
R003,Cali,Buenaventura,115
EOF
    cat > "$base/data/clientes.csv" <<'EOF'
id_cliente,nombre,ciudad
C01,Distribuidora Andina,Cali
C02,Frutas del Valle,Palmira
EOF
    cat > "$base/data/vehiculos.csv" <<'EOF'
placa,tipo,capacidad_kg
ABC123,camion,8000
DEF456,furgon,2500
EOF
    echo "Notas del equipo de datos de LogiTrans." > "$base/data/notas_operativas.txt"

    cat > "$base/frontend/index.html" <<'EOF'
<!doctype html>
<html><head><meta charset="utf-8"><title>RutaFácil</title>
<link rel="stylesheet" href="styles.css"></head>
<body><h1>RutaFácil - LogiTrans</h1><script src="app.js"></script></body></html>
EOF
    echo "console.log('RutaFácil frontend');" > "$base/frontend/app.js"
    printf 'body { font-family: sans-serif; }\nh1 { color: #0a5; }\n' > "$base/frontend/styles.css"

    cat > "$base/backend/start_backend.sh" <<'EOF'
#!/bin/bash
# Arranque (simulado) del backend de RutaFácil
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/config.env"
echo "Backend RutaFácil iniciado en el puerto $PORT (modo $MODO)"
EOF
    printf 'PORT=8080\nMODO=produccion\nDB_HOST=db.logitrans.local\n' > "$base/backend/config.env"
    cat > "$base/backend/api.py" <<'EOF'
# Modulo de la API (simulado)
def saludo():
    return "RutaFácil API"
EOF

    # Tarea de ejemplo que consume CPU (termina sola a los 20 minutos)
    cat > "$base/tools/carga.sh" <<'EOF'
#!/bin/bash
# Simula una tarea que consume CPU. Termina sola a los 20 minutos.
fin=$((SECONDS + 1200))
while [ "$SECONDS" -lt "$fin" ]; do :; done
EOF

    # Estado inicial: carpetas 755, archivos 644; start_backend.sh 754; carga.sh 755
    find "$base" -type d -exec chmod 755 {} +
    find "$base" -type f -exec chmod 644 {} +
    chmod 754 "$base/backend/start_backend.sh"
    chmod 755 "$base/tools/carga.sh"

    # ---- Script y servicio del sistema (propiedad de root) ----
    sudo install -m 644 -o root -g root /dev/null /usr/local/bin/ruta_monitor.sh || return 1
    sudo tee /usr/local/bin/ruta_monitor.sh > /dev/null <<'EOF'
#!/bin/bash
# Servicio (simulado) de RutaFácil: escribe un mensaje cada 5 segundos
while true; do
    echo "RutaFácil ruta_monitor: $(date '+%F %T') - servicio en ejecucion"
    sleep 5
done
EOF
    sudo chmod 644 /usr/local/bin/ruta_monitor.sh

    sudo install -m 644 -o root -g root /dev/null /etc/systemd/system/ruta_monitor.service || return 1
    sudo tee /etc/systemd/system/ruta_monitor.service > /dev/null <<'EOF'
[Unit]
Description=Servicio ruta_monitor de RutaFácil (LogiTrans)
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ruta_monitor.sh

[Install]
WantedBy=multi-user.target
EOF
    sudo chmod 644 /etc/systemd/system/ruta_monitor.service

    if [ -d /run/systemd/system ]; then
        sudo systemctl daemon-reload
        echo "Servicio 'ruta_monitor' registrado en systemd."
    else
        echo "ADVERTENCIA: systemd no esta activo en este sistema."
        echo "  Las preguntas de servicios lo requieren (verifique con: ps -p 1 -o comm=)."
    fi

    echo "==================================================="
    echo "Ambiente creado: /opt/rutafacil, /usr/local/bin/ruta_monitor.sh"
    echo "y /etc/systemd/system/ruta_monitor.service"
    echo "Ya puede iniciar la evaluación."
}

_setup_parcial_A
_rc=$?
unset -f _setup_parcial_A
(return 0 2>/dev/null) && return $_rc || exit $_rc
