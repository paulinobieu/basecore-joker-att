#!/usr/bin/env node
// Roda javascript-obfuscator no bundle de entrada gerado pelo Vite.
// Le web/index.html, descobre o chunk de entrada (<script type="module" src="./assets/index-*.js">)
// e obfusca esse arquivo in-place via API JS. Fallback: maior index-*.js em web/assets.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import JavaScriptObfuscator from 'javascript-obfuscator';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const WEB_DIR = path.resolve(__dirname, '..', 'web');
const ASSETS_DIR = path.join(WEB_DIR, 'assets');
const INDEX_HTML = path.join(WEB_DIR, 'index.html');

if (!fs.existsSync(ASSETS_DIR)) {
  console.error('✗ assets/ não encontrado em', ASSETS_DIR);
  process.exit(1);
}

// 1) Tenta achar o entry referenciado no index.html
let entry = null;
if (fs.existsSync(INDEX_HTML)) {
  const html = fs.readFileSync(INDEX_HTML, 'utf8');
  const m = html.match(/<script[^>]*type="module"[^>]*src="\.?\/?(assets\/[^"]+\.js)"/i);
  if (m) {
    const candidate = path.join(WEB_DIR, m[1]);
    if (fs.existsSync(candidate)) entry = candidate;
  }
}

// 2) Fallback: maior index-*.js
if (!entry) {
  entry = fs
    .readdirSync(ASSETS_DIR)
    .filter((f) => /^index-.*\.js$/.test(f))
    .map((f) => path.join(ASSETS_DIR, f))
    .sort((a, b) => fs.statSync(b).size - fs.statSync(a).size)[0];
}

if (!entry) {
  console.error('✗ Nenhum chunk de entrada encontrado em', ASSETS_DIR);
  process.exit(1);
}

console.log('→ Obfuscando', path.relative(process.cwd(), entry));

const source = fs.readFileSync(entry, 'utf8');
const result = JavaScriptObfuscator.obfuscate(source, {
  compact: true,
  controlFlowFlattening: true,
  deadCodeInjection: true,
  stringArray: true,
  stringArrayEncoding: ['base64'],
  disableConsoleOutput: true,
});

fs.writeFileSync(entry, result.getObfuscatedCode(), 'utf8');
console.log('✓ Obfuscação concluída');
