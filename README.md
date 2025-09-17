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
