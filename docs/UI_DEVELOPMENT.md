# Guia de Desarrollo UI - RadioShack Wireless N300M

Como modificar la interfaz web del router, correr un server local y subir los cambios.

## Estructura del Proyecto

```
radio_shack_wireless_n300/
├── docs/
│   ├── EXTRACTION_GUIDE.md    # Guia de extraccion del firmware
│   └── UI_DEVELOPMENT.md      # Este archivo
├── firmware/
│   ├── mtd0.bin               # Bootloader + Kernel
│   ├── mtd1.bin               # Rootfs SquashFS
│   └── firmware_RTL8196E_N300M.bin
└── squashfs-root/             # Rootfs extraido (en tu home)
    └── web/                   # Archivos de la interfaz web
        ├── indexRouter.html   # Pagina principal
        ├── upgrade.html       # Actualizacion de firmware
        ├── admin.html         # Cambio de password
        ├── system.html        # Sistema
        ├── ext_wireless.html  # Config inalambrica
        ├── network.html       # Config LAN
        ├── internet.html      # Config WAN
        ├── css/               # Estilos
        ├── js/                # JavaScript
        ├── images/            # Iconos e imagenes
        └── main/              # Subpaginas
```

## Correr el Server Local

Desde la raiz del proyecto:

```bash
python3 router_web.py
```

Abre **http://localhost:8080** en tu navegador.

El server redirige `index.htm` a `indexRouter.html` automaticamente porque el original usa server-side templates que solo funcionan en el router real.

### Detener el Server

```bash
kill $(lsof -ti :8080)
```

## Archivos Clave

### indexRouter.html
Pagina principal. Contiene el menu lateral y un iframe que carga las subpaginas.

### css/style.css
Estilos generales del menu y layout.

### css/upgrade.css, admin.css, system.css
Estilos especificos de cada pagina.

### js/jquery-1.2.1.min.js
jQuery viejo que usa el router.

### util_gw.js
Funciones JavaScript compartidas (validaciones, helpers).

## Modificar el UI

### Cambiar Colores

Edita `css/style.css`:

```css
/* Colores del header */
#header { background: #1a1a2e; }
#router-header span { color: #ffffff; }

/* Menu lateral */
#left_col { background: #16213e; }
#accordion > li > div { color: #e0e0e0; }

/* Botones */
#Save_btn { background: #0f3460; color: white; }
```

### Cambiar el Logo

Reemplaza `images/logo.png` con tu imagen (mismas dimensiones recomendadas).

### Cambiar Textos

Busca los strings directamente en los archivos HTML. Por ejemplo en `indexRouter.html`:

```html
<!-- Original -->
<a href="main/routermain.html" target="col1"><img src="images/home.png">&nbsp;Inicio</a>

<!-- Modificado -->
<a href="main/routermain.html" target="col1"><img src="images/home.png">&nbsp;Dashboard</a>
```

### Cambiar la Paleta de Colores Completa

Busca y reemplaza los colores hex en todos los archivos CSS:

```bash
# Encontrar todos los colores usados
grep -rh "#[0-9a-fA-F]\{3,6\}" css/ | sort -u
```

### Agregar una Pagina Nueva

1. Crea el archivo HTML en `/web/mipagina.html`
2. Agrega el link en `indexRouter.html` dentro del menu `<ul id="accordion">`:

```html
<li>
    <div id="menu_img"><a href="#"><img src="images/miicono.png">&nbsp;Mi Pagina</a></div>
    <ul>
        <li><a href="mipagina.html" target="col1"><div id="submenu_img"><img src="images/miicono.png">&nbsp;Sub Item</div></a></li>
    </ul>
</li>
```

### Modificar el Firmware Upgrade

El form de upgrade esta en `upgrade.html`. El endpoint es `/boafrm/formUpload` y solo acepta archivos `.bin`.

### Quitar Paginas del Menu

Comenta o elimina el `<li>` correspondiente en `indexRouter.html`.

## Subir Cambios al Router Real

### Opcion 1: Via Web UI (recomendado)

1. Empaqueta los archivos modificados en un `.bin` o usa la herramienta `mksquashfs`
2. Sube via `http://192.168.1.153/upgrade.html`

### Opcion 2: Via Telnet

```bash
# Conectarse al router
telnet 192.168.1.153
# user: root
# pass: password

# El directorio /web es SquashFS (read-only)
# Pero /var/web/ es writable (ramfs)
# Se puede modificar la config de Boa para servir desde /var/web
```

### Opcion 3: Recompilar el Rootfs

```bash
# 1. Modificar archivos en squashfs-root/web/
# 2. Recompilar SquashFS
mksquashfs squashfs-root/ mtd1_new.bin -comp xz -b 131072

# 3. Flashear via telnet
# ( desde el router )
cat /tmp/mtd1_new.bin > /dev/mtdblock1
reboot
```

## Templates Server-Side

El router original usa templates de Boa. Tags como:

```
<% getIndex("opMode") %>
<% getInfo("wlan0-status") %>
<% setBootLine("boot", "test") %>
```

Estos **no funcionan** en el server local. Para desarrollo local, hardcodea los valores:

```html
<!-- Original -->
<script>var opmode = <% getIndex("opMode"); %>;</script>

<!-- Para desarrollo local -->
<script>var opmode = 0;</script>
```

## Limitaciones

- El router tiene **24 MB de RAM** - no subas archivos grandes
- BusyBox es muy minimo: no hay `sed`, `chmod`, `dd`, `wget`
- SquashFS es **read-only** - para modificar hay que recompilar
- El Boa web server no soporta PHP ni CGI complejo
- jQuery 1.2.1 - no uses features modernas de JS

## Comandos Utiles

```bash
# Ver archivos del firmware extraido
ls -la squashfs-root/web/

# Buscar un string en todos los HTML
grep -rn "texto" squashfs-root/web/

# Verificar que el server local funciona
curl -s http://localhost:8080/ | head -5

# Ver procesos del server local
ps aux | grep router_web
```
