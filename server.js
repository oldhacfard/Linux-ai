const http = require('http');
const fs = require('fs');

const PORT = process.env.PORT || 3000;
const LOG_FILE = 'ai_logs.txt';

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    return res.end();
  }

  if (req.method === 'POST' && req.url === '/log') {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', () => {
      const timestamp = new Date().toISOString();
      const logEntry = `[${timestamp}] ${body}\n`;
      console.log(logEntry.trim());
      fs.appendFileSync(LOG_FILE, logEntry);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'saved', timestamp }));
    });
  } else if (req.method === 'GET' && req.url === '/logs') {
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    if (!fs.existsSync(LOG_FILE)) return res.end('Henüz kayıtlı log yok.');
    res.end(fs.readFileSync(LOG_FILE, 'utf8'));
  } else {
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Render Linux Log Sunucusu Çalışıyor.');
  }
});

server.listen(PORT, () => {
  console.log(`Sunucu ${PORT} portunda aktif...`);
});

