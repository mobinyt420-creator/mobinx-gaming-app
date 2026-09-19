import http from 'http';
import https from 'https';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PORT = 5173;

const MIME_TYPES = {
  '.html': 'text/html; charset=UTF-8',
  '.css': 'text/css; charset=UTF-8',
  '.js': 'application/javascript; charset=UTF-8',
  '.json': 'application/json; charset=UTF-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.apk': 'application/vnd.android.package-archive'
};

const server = http.createServer((req, res) => {
  let reqPath = decodeURI(req.url.split('?')[0]);

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    });
    res.end();
    return;
  }

  // Handle FCM Push Broadcast Proxy
  if (reqPath === '/api/send-fcm' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const serverKey = payload.serverKey || process.env.FCM_SERVER_KEY;
        const notif = payload.notification || payload;

        if (!serverKey) {
          res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
          res.end(JSON.stringify({ success: false, message: 'FCM Server Key not provided. Live Firestore Real-Time Sync was dispatched.' }));
          return;
        }

        const topics = ['all', 'all_users', 'mobinx_broadcast', 'obin_broadcast'];
        const fcmPayload = {
          priority: 'high',
          notification: {
            title: notif.title || 'OBIN Announcement',
            body: notif.message || notif.desc || '',
            sound: 'default',
            android_channel_id: 'mobinx_high_importance_channel',
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          },
          data: {
            title: notif.title || 'OBIN Announcement',
            body: notif.message || notif.desc || '',
            message: notif.message || notif.desc || '',
            type: notif.type || 'general',
            targetUrl: notif.targetUrl || notif.actionUrl || '',
            actionUrl: notif.actionUrl || notif.targetUrl || '',
            id: notif.id || `notif_${Date.now()}`,
            broadcastId: notif.broadcastId || `bc_${Date.now()}`
          }
        };

        const promises = topics.map(topic => {
          return new Promise(resolve => {
            const dataStr = JSON.stringify({ ...fcmPayload, to: `/topics/${topic}` });
            const fcmReq = https.request('https://fcm.googleapis.com/fcm/send', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `key=${serverKey}`,
                'Content-Length': Buffer.byteLength(dataStr)
              }
            }, (fcmRes) => {
              let fcmBody = '';
              fcmRes.on('data', d => { fcmBody += d; });
              fcmRes.on('end', () => {
                resolve({ topic, status: fcmRes.statusCode, body: fcmBody });
              });
            });
            fcmReq.on('error', (err) => {
              resolve({ topic, error: err.message });
            });
            fcmReq.write(dataStr);
            fcmReq.end();
          });
        });

        Promise.all(promises).then(results => {
          res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
          res.end(JSON.stringify({ success: true, results }));
        });
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  if (reqPath === '/') reqPath = '/index.html';
  
  let filePath = path.join(__dirname, reqPath);
  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404, { 
          'Content-Type': 'text/plain',
          'Access-Control-Allow-Origin': '*'
        });
        res.end('404 Not Found: ' + reqPath);
      } else {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Server Error');
      }
    } else {
      res.writeHead(200, { 
        'Content-Type': contentType,
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Access-Control-Allow-Origin': '*'
      });
      res.end(content);
    }
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running locally at: http://localhost:${PORT}/`);
  console.log(`Mobile Phone Access URL: http://192.168.16.229:${PORT}/`);
});
