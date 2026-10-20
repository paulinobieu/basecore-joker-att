#!/usr/bin/env node
// Copia o build do NUI (web/) para os dois resources do repo:
// core-skins-opensource/web e core-skins/web (mirror com limpeza).

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const FRONT_DIR = path.resolve(__dirname, '..');
const REPO_ROOT = path.resolve(FRONT_DIR, '..');
const WEB_SRC = path.join(FRONT_DIR, 'web');

const DESTS = [
  path.join(REPO_ROOT, 'core-skins-opensource', 'web'),
  path.join(REPO_ROOT, 'core-skins', 'web'),
];

if (!fs.existsSync(WEB_SRC)) {
  console.error('✗ web/ não encontrado em', WEB_SRC);
  process.exit(1);
}

function clearDest(dest) {
  if (!fs.existsSync(dest)) return;
  try {
    fs.rmSync(dest, { recursive: true, force: true });
  } catch (e) {
    if (e.code === 'EBUSY' || e.code === 'EPERM') {
      for (const entry of fs.readdirSync(dest, { withFileTypes: true })) {
        try { fs.rmSync(path.join(dest, entry.name), { recursive: true, force: true }); } catch {}
      }
    } else {
      throw e;
    }
  }
}

function copyDir(src, dst) {
  let n = 0;
  fs.mkdirSync(dst, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dst, entry.name);
    if (entry.isDirectory()) n += copyDir(s, d);
    else { fs.copyFileSync(s, d); n++; }
  }
  return n;
}

console.log('');
console.log('📦 Sincronizando web/ para os resources:');

for (const dest of DESTS) {
  clearDest(dest);
  const n = copyDir(WEB_SRC, dest);
  console.log(`   ✓ ${path.relative(REPO_ROOT, dest)} (${n} arquivos)`);
}

console.log('');
