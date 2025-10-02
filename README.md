<<<<<<< HEAD
# Software_ll - Sistema de Inventarios

Este repositorio contiene dos implementaciones del sistema de inventarios para Muebles Lusander:

## 📱 InventarioApp - Flutter + Supabase

Una aplicación móvil completa de gestión de inventarios desarrollada en Flutter con backend en Supabase.

### 🚀 Características

#### Roles de Usuario
- **Administrador General**: Gestión completa de usuarios, productos, inventario, pedidos y reportes
- **Vendedor**: Gestión de productos, inventario, pedidos y ventas (limitado)
- **Cliente**: Tienda, carrito, pedidos y perfil

#### Funcionalidades Principales
- ✅ **Autenticación completa** con Supabase Auth
- ✅ **Gestión de usuarios y roles**
- ✅ **CRUD completo de productos**
- ✅ **Control de inventario en tiempo real**
- ✅ **Sistema de pedidos con validación de stock**
- ✅ **Carrito de compras funcional**
- ✅ **Búsqueda de productos**
- ✅ **Métricas y reportes en tiempo real**

### 🛠️ Instalación y Configuración

#### Paso 1: Configurar Supabase
1. Ve a [supabase.com](https://supabase.com) y crea una cuenta
2. Crea un nuevo proyecto
3. Ve a **Settings > API**
4. Copia tu **Project URL** y **anon/public key**

#### Paso 2: Configurar Base de Datos
1. Ve a **SQL Editor** en tu panel de Supabase
2. Ejecuta el script completo que está en `database/setup.sql`
3. Ejecuta los datos de prueba con `datos_prueba.sql`

#### Paso 3: Configurar Credenciales
1. Abre `lib/config/supabase_config.dart`
2. Reemplaza con tus credenciales reales de Supabase

#### Paso 4: Ejecutar
```bash
cd inventario_app
flutter pub get
flutter run
```

---

## 🌐 MARLINE Dashboard - Interfaz Web

Interfaz web MARLINE Dashboard para Muebles Lusander (HTML + CSS puro).

### Estructura
- web/assets/global.css – Variables, layout y estilos globales (sidebar, topbar, cards, tablas, forms, panel preview, responsive)
- web/pages/ – Páginas estáticas con datos ficticios
	- login.html, dashboard.html, productos.html, inventario.html
	- ventas.html, ordenes.html, reportes.html, usuarios.html, etc.

### Cómo usar
1. Abrir cualquier archivo HTML en el navegador (doble clic) o servir la carpeta `web` con un servidor estático.
2. Las rutas de CSS y navegación son relativas, por lo que funcionan abriendo el archivo localmente.

### Diseño
- Paleta y tokens basados en variables CSS: `--bg`, `--sidebar`, `--surface`, `--text`, `--primary`, etc.
- Estilo "MARLINE Dashboard" con sidebar compact/expand, cards con radius 12px, tablas densas
- Responsive: grid 3 columnas en ≥1200px, 1 columna en móvil

---

## 🏗️ Arquitectura del Proyecto Flutter

### Stack Tecnológico
- **Frontend**: Flutter 3.35.1 (Dart)
- **Backend**: Supabase (PostgreSQL + Real-time API)
- **Patrón**: MVVM con Riverpod para gestión de estado
- **Autenticación**: Supabase Auth con roles personalizados

### Estructura del Código
```
lib/
├── models/           # Entidades de datos (Usuario, Producto, Pedido)
├── services/         # Capa de acceso a datos (Supabase)
├── controllers/      # Lógica de negocio (Riverpod StateNotifiers)
├── views/           # UI Components
│   ├── auth/        # Login, registro, splash
│   ├── admin/       # Dashboard administrativo
│   ├── vendedor/    # Dashboard de vendedor
│   └── cliente/     # Interfaz de tienda
└── config/          # Configuración de Supabase
```

¡El sistema está listo para usar! 🎉
=======
# Software_ll

Interfaz web MARLINE Dashboard para Muebles Lusander (HTML + CSS puro).

Estructura
- web/assets/global.css – Variables, layout y estilos globales (sidebar, topbar, cards, tablas, forms, panel preview, responsive)
- web/pages/ – Páginas estáticas con datos ficticios
	- login.html
	- dashboard.html
	- productos.html, producto.html
	- inventario.html
	- ventas.html
	- ordenes.html
	- recepcion.html
	- ajustes.html
	- devoluciones.html
	- reportes.html
	- usuarios.html
	- alertas.html

Cómo usar
1. Abrir cualquier archivo HTML en el navegador (doble clic) o servir la carpeta `web` con un servidor estático.
2. Las rutas de CSS y navegación son relativas, por lo que funcionan abriendo el archivo localmente.

Mockups (PNG/PDF)
- Rápido: abrir en Edge/Chrome, Device Toolbar móvil y capturar pantalla (PNG/PDF).
- Automatizado (Playwright):
	```powershell
	cd "c:\Users\Samue\OneDrive\Documents\EE_Scraping\Software_ll"
	npm init -y
	npm i -D playwright
	npx playwright install chromium
	node .\tools\capture-mockups.mjs
	start .\mockups
	```

Diseño
- Paleta y tokens basados en variables CSS: `--bg`, `--sidebar`, `--surface`, `--text`, `--text-muted`, `--primary`, `--green`, `--red`, `--gold`.
- Estilo “MARLINE Dashboard” con sidebar compact/expand (72/240px), topbar minimal, cards radius 12px, tablas densas, panel de preview a la derecha activado con `:target`.
- Responsive: grid 3 columnas en ≥1200px, 1 columna en móvil.

Accesibilidad
- Contraste AA y foco visible con anillo azul.
- Targets de 40×40px en botones principales.
>>>>>>> d08319fd2eb240bc2ef0a8374c5ab35bae760cbd
