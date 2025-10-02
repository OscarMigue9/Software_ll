import fs from 'fs';
import path from 'path';
import { chromium } from 'playwright';

const root = path.resolve('web', 'pages');
const outDir = path.resolve('mockups');
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

const roleSections = [
  { role: 'Administrador', files: ['admin.html','dashboard.html','usuarios.html','reportes.html','ajustes.html','alertas.html'] },
  { role: 'Vendedor', files: ['vendedor.html','productos.html','producto.html','inventario.html','ventas.html','ordenes.html'] },
  { role: 'Cliente', files: ['tienda.html','producto_publico.html','carrito.html','checkout.html','pedido.html','login_cliente.html','cliente.html'] }
];
const pages = roleSections.flatMap(s => s.files).filter(f => fs.existsSync(path.join(root, f)));

const sizes = [
  { name: 'desktop', width: 1440, height: 900 },
  { name: 'mobile',  width: 390,  height: 844 }
];

const toFileUrl = p => 'file:///' + p.replace(/\\/g, '/');

(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ deviceScaleFactor: 1 });
  const page = await ctx.newPage();
  const shots = [];
  const shotsByRole = new Map(roleSections.map(s => [s.role, []]));

  for (const file of pages) {
    const url = toFileUrl(path.resolve(root, file));
    for (const s of sizes) {
      await page.setViewportSize({ width: s.width, height: s.height });
      await page.goto(url, { waitUntil: 'load' });
      await page.waitForTimeout(250);
      const out = path.join(outDir, `${path.parse(file).name}_${s.name}.png`);
      await page.screenshot({ path: out, fullPage: true });
      const shot = { title: `${file} – ${s.name}`, path: out, kind: s.name, file };
      shots.push(shot);
      for (const sec of roleSections) {
        if (sec.files.includes(file)) shotsByRole.get(sec.role).push(shot);
      }
      console.log('✓', out);
    }
  }

  const html = `<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8"/>
<title>Mockups</title>
<style>
  :root { --bg:#F5F7FA; --surface:#FFF; --text:#0B1220; }
  body { margin:0; background:var(--bg); color:var(--text); font:14px/1.5 Inter, system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; }
  .page { max-width: 960px; margin: 24px auto; background: var(--surface); padding: 16px; border-radius: 12px; box-shadow: 0 4px 16px rgba(0,0,0,.06); page-break-after: always; break-after: page; }
  h2 { margin: 8px 0 12px; font-size: 16px; }
  h1 { max-width: 960px; margin: 32px auto 8px; font-size: 18px; font-weight: 600; }
  img { width: 100%; height: auto; border-radius: 8px; border: 1px solid rgba(0,0,0,.08); }
  img.mobile { width: 50%; display: block; margin: 0 auto; }
  .grid { display: grid; gap: 16px; }
</style>
</head>
<body>
  ${roleSections.map(sec => `
    <h1>${sec.role}</h1>
    ${shotsByRole.get(sec.role).map(s => `
      <div class="page">
        <h2>${s.title}</h2>
        <div class="grid"><img class="${s.kind === 'mobile' ? 'mobile' : ''}" src="${path.basename(s.path)}" alt="${s.title}"/></div>
      </div>
    `).join('')}
  `).join('')}
</body>
</html>`;

  fs.writeFileSync(path.join(outDir, 'index.html'), html, 'utf8');

  const pdfPage = await ctx.newPage();
  await pdfPage.goto(toFileUrl(path.join(outDir, 'index.html')));
  const client = await ctx.newCDPSession(pdfPage);
  const { data } = await client.send('Page.printToPDF', { printBackground: true, displayHeaderFooter: false, paperWidth: 8.27, paperHeight: 11.69 });
  fs.writeFileSync(path.join(outDir, 'mockups.pdf'), Buffer.from(data, 'base64'));

  await browser.close();
  console.log('✓ mockups/index.html');
  console.log('✓ mockups/mockups.pdf');
})();
