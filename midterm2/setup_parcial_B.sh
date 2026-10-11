#!/bin/bash
# =====================================================================
#  Evaluación práctica B - EduSoft / CampusHub
#  Ubuntu (WSL2 o Multipass).  Uso:   source setup_parcial_B.sh
#  (también funciona con:  bash setup_parcial_B.sh)
#  Este script SOLO puede ejecutarse una vez.
# =====================================================================

_setup_parcial_B() {
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
    echo "(crea /opt/campushub y archivos del sistema).      "
    echo "==================================================="

    me="$(id -un)"
    migrupo="$(id -gn)"
    base=/opt/campushub

    if [ -e "$base" ]; then
        echo "ERROR: $base ya existe. El ambiente ya fue creado anteriormente."
        return 1
    fi

    # ---- Estructura de la aplicación (propiedad de la cuenta actual) ----
    sudo install -d -m 755 -o "$me" -g "$migrupo" "$base" || return 1
    mkdir -p "$base"/data "$base"/frontend "$base"/backend "$base"/tools || return 1

    cat > "$base/data/matriculas_2025.csv" <<'EOF'
id_matricula,id_estudiante,id_curso,periodo
M001,E10,C01,2025-1
M002,E11,C02,2025-1
M003,E12,C01,2025-1
EOF
    cat > "$base/data/cursos.csv" <<'EOF'
id_curso,nombre,creditos
C01,Sistemas Operativos,3
C02,Bases de Datos,4
EOF
    cat > "$base/data/estudiantes.csv" <<'EOF'
id_estudiante,nombre,programa
E10,Ana Ruiz,Ingenieria
E11,Luis Mora,Ingenieria
E12,Eva Soto,Diseno
EOF
    echo "Notas del equipo de datos de EduSoft." > "$base/data/notas_calidad.txt"

    cat > "$base/frontend/index.html" <<'EOF'
<!doctype html>
<html><head><meta charset="utf-8"><title>CampusHub</title>
<link rel="stylesheet" href="styles.css"></head>
<body><h1>CampusHub - EduSoft</h1><script src="app.js"></script></body></html>
EOF
    echo "console.log('CampusHub frontend');" > "$base/frontend/app.js"
    printf 'body { font-family: sans-serif; }\nh1 { color: #0a5; }\n' > "$base/frontend/styles.css"

    cat > "$base/backend/start_backend.sh" <<'EOF'
#!/bin/bash
# Arranque (simulado) del backend de CampusHub
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/config.env"
echo "Backend CampusHub iniciado en el puerto $PORT (modo $MODO)"
EOF
    printf 'PORT=9090\nMODO=produccion\nDB_HOST=db.edusoft.local\n' > "$base/backend/config.env"
    cat > "$base/backend/api.py" <<'EOF'
# Modulo de la API (simulado)
def saludo():
    return "CampusHub API"
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
    sudo install -m 644 -o root -g root /dev/null /usr/local/bin/campus_sync.sh || return 1
    sudo tee /usr/local/bin/campus_sync.sh > /dev/null <<'EOF'
#!/bin/bash
# Servicio (simulado) de CampusHub: escribe un mensaje cada 5 segundos
while true; do
    echo "CampusHub campus_sync: $(date '+%F %T') - servicio en ejecucion"
    sleep 5
done
EOF
    sudo chmod 644 /usr/local/bin/campus_sync.sh

    sudo install -m 644 -o root -g root /dev/null /etc/systemd/system/campus_sync.service || return 1
    sudo tee /etc/systemd/system/campus_sync.service > /dev/null <<'EOF'
[Unit]
Description=Servicio campus_sync de CampusHub (EduSoft)
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/campus_sync.sh

[Install]
WantedBy=multi-user.target
EOF
    sudo chmod 644 /etc/systemd/system/campus_sync.service

    if [ -d /run/systemd/system ]; then
        sudo systemctl daemon-reload
        echo "Servicio 'campus_sync' registrado en systemd."
    else
        echo "ADVERTENCIA: systemd no esta activo en este sistema."
        echo "  Las preguntas de servicios lo requieren (verifique con: ps -p 1 -o comm=)."
    fi

    echo "==================================================="
    echo "Ambiente creado: /opt/campushub, /usr/local/bin/campus_sync.sh"
    echo "y /etc/systemd/system/campus_sync.service"
    echo "Ya puede iniciar la evaluación."
}

_setup_parcial_B
_rc=$?
unset -f _setup_parcial_B
(return 0 2>/dev/null) && return $_rc || exit $_rc
