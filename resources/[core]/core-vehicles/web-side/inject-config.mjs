// Pós-build: injeta o carregamento do config no index.html gerado pelo Vite.
// O Vite recria o dist/index.html a cada build (emptyOutDir), entao precisamos
// re-adicionar a tag que carrega window.VEHICLE_IMAGE_URL a partir do config
// do resource (config/config.ui.js), ANTES do bundle principal.
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const htmlPath = resolve("dist/index.html");
const tag = '<script src="../../config/config.ui.js"></script>';

let html = readFileSync(htmlPath, "utf8");

if (html.includes("config/config.ui.js")) {
  console.log("[postbuild] config.ui.js ja presente no index.html");
} else {
  // Insere a tag imediatamente antes do primeiro <script type="module" ...>
  html = html.replace(/(\s*)(<script type="module")/, `$1${tag}$1$2`);
  writeFileSync(htmlPath, html, "utf8");
  console.log("[postbuild] config.ui.js injetado no index.html");
}
