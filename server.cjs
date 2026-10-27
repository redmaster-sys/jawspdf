const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const root = __dirname;
const port = Number(process.env.PORT || 4290);
const userDownloadsRoot = path.join(process.env.USERPROFILE || root, 'Downloads');
const mainOutDir = path.join(userDownloadsRoot, 'JawsPDF_Ciktilar');
const projectOutDir = path.join(root, 'Ciktilar');
const uploadDir = path.join(root, 'Yuklenenler');
const sampleDir = path.join(root, 'Ornek_Dosyalar');
const pythonExe = path.join(root, '.venv', 'Scripts', 'python.exe');
const engineScript = path.join(root, 'pdf_engine.py');

fs.mkdirSync(mainOutDir, { recursive: true });
fs.mkdirSync(projectOutDir, { recursive: true });
fs.mkdirSync(uploadDir, { recursive: true });
fs.mkdirSync(sampleDir, { recursive: true });

const mime = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.pdf': 'application/pdf',
  '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  '.pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  '.zip': 'application/zip',
  '.md': 'text/markdown; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8'
};

function mirrorOutputEverywhere(filePath) {
  try {
    if (!filePath || !fs.existsSync(filePath)) return;
    const base = path.basename(filePath);
    const dstMain = path.join(mainOutDir, base);
    const dstDownloads = path.join(userDownloadsRoot, base);
    const dstProj = path.join(projectOutDir, base);
    for (const dst of [dstMain, dstDownloads, dstProj]) {
      if (path.resolve(filePath) !== path.resolve(dst)) {
        fs.copyFileSync(filePath, dst);
      }
    }
  } catch (_) {}
}

function listOutputFiles() {
  try {
    return fs.readdirSync(projectOutDir)
      .map(name => {
        const full = path.join(projectOutDir, name);
        const st = fs.statSync(full);
        if (!st.isFile()) return null;
        return {
          name,
          fullPath: path.join(mainOutDir, name),
          projectPath: full,
          sizeKB: Number((st.size / 1024).toFixed(1)),
          mtimeMs: st.mtimeMs,
          mtime: new Date(st.mtimeMs).toLocaleString('tr-TR'),
          downloadUrl: `/api/download?name=${encodeURIComponent(name)}`,
          inlineUrl: `/api/download?name=${encodeURIComponent(name)}&inline=1`
        };
      })
      .filter(Boolean)
      .sort((a, b) => b.mtimeMs - a.mtimeMs);
  } catch (_) {
    return [];
  }
}

function openFolderInExplorer(targetDir) {
  const escaped = targetDir.replace(/'/g, "''");
  const psCmd = `(New-Object -ComObject Shell.Application).Open('${escaped}')`;
  const child = spawn('powershell.exe', ['-NoProfile', '-Command', psCmd], {
    detached: true,
    stdio: 'ignore'
  });
  child.unref();
}

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    let chunks = [];
    req.on('data', c => chunks.push(c));
    req.on('end', () => {
      try {
        const raw = Buffer.concat(chunks).toString('utf8');
        resolve(JSON.parse(raw || '{}'));
      } catch (e) {
        reject(e);
      }
    });
  });
}

function invokePythonEngine(payload) {
  return new Promise((resolve, reject) => {
    const proc = spawn(pythonExe, [engineScript], {
      cwd: root,
      windowsHide: true
    });
    let out = '';
    let err = '';
    proc.stdout.on('data', d => { out += d.toString('utf8'); });
    proc.stderr.on('data', d => { err += d.toString('utf8'); });
    proc.on('close', () => {
      try {
        const lines = out.trim().split(/\r?\n/);
        const lastJsonLine = lines.reverse().find(l => l.trim().startsWith('{')) || '{}';
        const parsed = JSON.parse(lastJsonLine);
        resolve(parsed);
      } catch (e) {
        reject(new Error(err || out || e.message));
      }
    });
    proc.stdin.write(JSON.stringify(payload));
    proc.stdin.end();
  });
}

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const sendJson = (code, obj) => {
    res.writeHead(code, {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store'
    });
    res.end(JSON.stringify(obj));
  };

  if (req.method === 'GET' && req.url === '/api/status') {
    return sendJson(200, {
      ok: true,
      appName: 'JawsPDF',
      mainOutDir,
      projectOutDir,
      files: listOutputFiles()
    });
  }

  if (req.method === 'POST' && req.url === '/api/upload') {
    try {
      const body = await readJsonBody(req);
      const files = Array.isArray(body.files) ? body.files : [];
      const savedPaths = [];
      for (const f of files) {
        const safeName = String(f.name || 'belge.pdf').replace(/[<>:"/\\|?*\x00-\x1F]/g, '_');
        const b64 = String(f.dataUrl || '').includes(',')
          ? String(f.dataUrl).split(',')[1]
          : String(f.dataUrl || '');
        const dst = path.join(uploadDir, `${Date.now()}_${safeName}`);
        fs.writeFileSync(dst, Buffer.from(b64, 'base64'));
        savedPaths.push(dst);
      }
      return sendJson(200, { ok: true, savedPaths });
    } catch (e) {
      return sendJson(400, { ok: false, error: String(e.message || e) });
    }
  }

  if (req.method === 'POST' && req.url === '/api/run-tool') {
    try {
      const body = await readJsonBody(req);
      const result = await invokePythonEngine({
        toolId: body.toolId || 'merge',
        inputFiles: Array.isArray(body.inputFiles) ? body.inputFiles : [],
        options: body.options || {},
        outputDir: projectOutDir,
        sampleDir
      });
      if (result && result.ok && result.outputPath) {
        mirrorOutputEverywhere(result.outputPath);
        result.downloadUrl = `/api/download?name=${encodeURIComponent(result.outputName)}`;
        result.inlineUrl = `/api/download?name=${encodeURIComponent(result.outputName)}&inline=1`;
        result.mainDownloadsPath = path.join(mainOutDir, result.outputName);
      }
      result.files = listOutputFiles();
      return sendJson(200, result);
    } catch (e) {
      return sendJson(500, { ok: false, error: String(e.message || e) });
    }
  }

  if (req.method === 'POST' && req.url === '/api/open-folder') {
    openFolderInExplorer(mainOutDir);
    return sendJson(200, {
      ok: true,
      opened: mainOutDir,
      files: listOutputFiles()
    });
  }

  if (req.method === 'GET' && req.url.startsWith('/api/download')) {
    const u = new URL(req.url, `http://127.0.0.1:${port}`);
    const name = path.basename(u.searchParams.get('name') || '');
    const inline = u.searchParams.get('inline') === '1';
    const full = path.join(projectOutDir, name);
    if (!name || !fs.existsSync(full)) {
      res.writeHead(404).end('Dosya bulunamadı');
      return;
    }
    const ext = path.extname(full).toLowerCase();
    const headers = {
      'Content-Type': mime[ext] || 'application/octet-stream',
      'Cache-Control': 'no-store'
    };
    if (!inline) {
      headers['Content-Disposition'] = `attachment; filename="${encodeURIComponent(name)}"`;
    }
    res.writeHead(200, headers);
    fs.createReadStream(full).pipe(res);
    return;
  }

  const reqPath = decodeURIComponent((req.url || '/').split('?')[0]);
  const rel = reqPath === '/' ? 'index.html' : reqPath.replace(/^\/+/, '');
  const file = path.resolve(root, rel);
  if (!file.startsWith(root)) {
    res.writeHead(403).end('Yasak');
    return;
  }
  fs.readFile(file, (err, buf) => {
    if (err) {
      res.writeHead(404).end('Bulunamadı');
      return;
    }
    res.writeHead(200, {
      'Content-Type': mime[path.extname(file).toLowerCase()] || 'application/octet-stream',
      'Cache-Control': 'no-store'
    });
    res.end(buf);
  });
});

server.listen(port, '127.0.0.1', () => {
  console.log(`JawsPDF 30-Araçlı PDF Stüdyosu hazır: http://127.0.0.1:${port}`);
  console.log(`Çıktı Klasörü: ${mainOutDir}`);
});
