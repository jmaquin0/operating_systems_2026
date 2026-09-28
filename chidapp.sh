#!/usr/bin/env bash
# ------------------------------------------------------------------
# crear_mockup.sh
# Crea el mockup de una app (Spring Boot + React) en tu home y luego
# deja TODO como root:root con permisos 000 para practicar permisos.
#
# Uso:   ./crear_mockup.sh            (crea ~/chida-app)
#        ./crear_mockup.sh mi-carpeta (crea ~/mi-carpeta)
# Necesita sudo SOLO al final (chown y chmod).
# ------------------------------------------------------------------
set -euo pipefail

# Si lo corres con sudo, usar el home del usuario real, no el de root
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
NOMBRE="${1:-chida-app}"
BASE="$REAL_HOME/$NOMBRE"

if [ -e "$BASE" ]; then
  echo "Ya existe $BASE. Bórralo (sudo rm -rf \"$BASE\") o usa otro nombre." >&2
  exit 1
fi

echo ">> Creando estructura en $BASE"
mkdir -p "$BASE/backend/src/main/java/com/chida/app"
mkdir -p "$BASE/backend/src/main/resources"
mkdir -p "$BASE/frontend/src"

# ============================ BACKEND ============================
cat > "$BASE/backend/pom.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.3.4</version>
    <relativePath/>
  </parent>

  <groupId>com.chida</groupId>
  <artifactId>app</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <name>chida-app-backend</name>

  <properties>
    <java.version>17</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat > "$BASE/backend/src/main/java/com/chida/app/ChidaApplication.java" <<'EOF'
package com.chida.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ChidaApplication {
    public static void main(String[] args) {
        SpringApplication.run(ChidaApplication.class, args);
    }
}
EOF

cat > "$BASE/backend/src/main/java/com/chida/app/Item.java" <<'EOF'
package com.chida.app;

public record Item(int id, String nombre, String descripcion, double precio) {}
EOF

cat > "$BASE/backend/src/main/java/com/chida/app/ItemController.java" <<'EOF'
package com.chida.app;

import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

@RestController
@RequestMapping("/api/items")
@CrossOrigin(origins = "http://localhost:5173")
public class ItemController {

    private final List<Item> items = new ArrayList<>(List.of(
        new Item(1, "Café de la casa", "Grano de origen, tostión media", 8500),
        new Item(2, "Arepa con queso", "Recién hecha en la plancha", 6000),
        new Item(3, "Jugo de lulo", "Natural, sin azúcar añadida", 7000)
    ));
    private final AtomicInteger seq = new AtomicInteger(3);

    @GetMapping
    public List<Item> listar() {
        return items;
    }

    @PostMapping
    public Item crear(@RequestBody Item nuevo) {
        Item item = new Item(seq.incrementAndGet(), nuevo.nombre(), nuevo.descripcion(), nuevo.precio());
        items.add(item);
        return item;
    }
}
EOF

cat > "$BASE/backend/src/main/resources/application.properties" <<'EOF'
spring.application.name=chida-app
server.port=8080
EOF

# ============================ FRONTEND ===========================
cat > "$BASE/frontend/package.json" <<'EOF'
{
  "name": "chida-app-frontend",
  "private": true,
  "version": "0.0.1",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.1",
    "vite": "^5.4.0"
  }
}
EOF

cat > "$BASE/frontend/vite.config.js" <<'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: { '/api': 'http://localhost:8080' }
  }
})
EOF

cat > "$BASE/frontend/index.html" <<'EOF'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Chida App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > "$BASE/frontend/src/main.jsx" <<'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './App.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
EOF

cat > "$BASE/frontend/src/App.jsx" <<'EOF'
import { useEffect, useState } from 'react'

export default function App() {
  const [items, setItems] = useState([])
  const [form, setForm] = useState({ nombre: '', descripcion: '', precio: '' })

  const cargar = () =>
    fetch('/api/items').then(r => r.json()).then(setItems).catch(console.error)

  useEffect(() => { cargar() }, [])

  const enviar = async (e) => {
    e.preventDefault()
    await fetch('/api/items', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...form, precio: Number(form.precio) })
    })
    setForm({ nombre: '', descripcion: '', precio: '' })
    cargar()
  }

  return (
    <main className="container">
      <h1>☕ Chida App</h1>
      <p className="sub">Mockup: Spring Boot + React</p>

      <form onSubmit={enviar} className="card form">
        <input placeholder="Nombre" value={form.nombre}
               onChange={e => setForm({ ...form, nombre: e.target.value })} required />
        <input placeholder="Descripción" value={form.descripcion}
               onChange={e => setForm({ ...form, descripcion: e.target.value })} />
        <input placeholder="Precio" type="number" value={form.precio}
               onChange={e => setForm({ ...form, precio: e.target.value })} required />
        <button type="submit">Agregar</button>
      </form>

      <section className="grid">
        {items.map(i => (
          <article key={i.id} className="card">
            <h3>{i.nombre}</h3>
            <p>{i.descripcion}</p>
            <strong>${i.precio.toLocaleString('es-CO')}</strong>
          </article>
        ))}
      </section>
    </main>
  )
}
EOF

cat > "$BASE/frontend/src/App.css" <<'EOF'
* { box-sizing: border-box; }
body { margin: 0; font-family: system-ui, sans-serif; background: #f5efe6; color: #2b2118; }
.container { max-width: 860px; margin: 0 auto; padding: 2rem 1rem; }
h1 { margin-bottom: 0; }
.sub { margin-top: .25rem; color: #7a6a58; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 1rem; margin-top: 1.5rem; }
.card { background: #fff; border-radius: 14px; padding: 1rem 1.25rem; box-shadow: 0 2px 8px rgba(0,0,0,.08); }
.form { display: flex; flex-wrap: wrap; gap: .5rem; margin-top: 1.5rem; }
.form input { flex: 1 1 140px; padding: .6rem; border: 1px solid #d8cbb8; border-radius: 8px; }
.form button { padding: .6rem 1.2rem; border: 0; border-radius: 8px; background: #c8642b; color: #fff; cursor: pointer; }
EOF

cat > "$BASE/README.md" <<'EOF'
# Chida App (mockup)

Backend: `cd backend && mvn spring-boot:run`  -> http://localhost:8080/api/items
Frontend: `cd frontend && npm install && npm run dev` -> http://localhost:5173
EOF

cat > "$BASE/.gitignore" <<'EOF'
node_modules/
target/
dist/
EOF

# ================== PRÁCTICA DE PERMISOS =========================
echo ">> Asignando root:root y permisos 000 (te pedirá sudo)"
sudo chown -R root:root "$BASE"
sudo chmod -R 000 "$BASE"

echo
echo "Listo. Verifica con:  sudo ls -laR $BASE | head -30"
echo "Para ver permisos sin entrar:  ls -ld $BASE"
echo "Para restaurar tu acceso:      sudo chown -R $REAL_USER:$REAL_USER $BASE && sudo chmod -R u+rwX,go+rX $BASE"
echo "Para borrarlo todo:            sudo rm -rf $BASE"
