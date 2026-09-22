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

  // Handle FCM Push Broadcast Proxy (FCM HTTP v1 + Legacy fallback)
  if (reqPath === '/api/send-fcm' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');
        const notif = payload.notification || payload;
        let serviceAccount = payload.serviceAccount;

        if (!serviceAccount && process.env.FIREBASE_SERVICE_ACCOUNT) {
          try {
            serviceAccount = typeof process.env.FIREBASE_SERVICE_ACCOUNT === 'string'
              ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
              : process.env.FIREBASE_SERVICE_ACCOUNT;
          } catch (_) {}
        }
        if (typeof serviceAccount === 'string') {
          try { serviceAccount = JSON.parse(serviceAccount); } catch (_) {}
        }

        const topics = ['all', 'all_users', 'mobinx_broadcast', 'obin_broadcast'];

        // 1. Modern FCM HTTP v1 using Service Account JWT
        if (serviceAccount && serviceAccount.client_email && serviceAccount.private_key) {
          const crypto = await import('crypto');
          const projectId = serviceAccount.project_id || 'obin-shop';
          
          const now = Math.floor(Date.now() / 1000);
          const header = { alg: 'RS256', typ: 'JWT' };
          const jwtPayload = {
            iss: serviceAccount.client_email,
            scope: 'https://www.googleapis.com/auth/firebase.messaging',
            aud: 'https://oauth2.googleapis.com/token',
            exp: now + 3600,
            iat: now
          };
          const b64 = (obj) => Buffer.from(JSON.stringify(obj)).toString('base64url');
          const unsigned = `${b64(header)}.${b64(jwtPayload)}`;
          const sign = crypto.createSign('RSA-SHA256');
          sign.update(unsigned);
          sign.end();
          const sig = sign.sign(serviceAccount.private_key, 'base64url');
          const jwt = `${unsigned}.${sig}`;

          const tokenData = await new Promise((resolve, reject) => {
            const postData = `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`;
            const reqOauth = https.request('https://oauth2.googleapis.com/token', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': Buffer.byteLength(postData)
              }
            }, (resOauth) => {
              let d = '';
              resOauth.on('data', c => { d += c; });
              resOauth.on('end', () => {
                try {
                  const p = JSON.parse(d);
                  if (resOauth.statusCode === 200 && p.access_token) resolve(p);
                  else reject(new Error(p.error_description || p.error || d));
                } catch(e) { reject(e); }
              });
            });
            reqOauth.on('error', reject);
            reqOauth.write(postData);
            reqOauth.end();
          });

          const accessToken = tokenData.access_token;

          // Helper to fetch tokens from Firestore
          const deviceTokens = await new Promise((resolve) => {
            const reqFs = https.request(`https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/fcm_tokens`, {
              method: 'GET',
              headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Accept': 'application/json'
              }
            }, (resFs) => {
              let dFs = '';
              resFs.on('data', c => { dFs += c; });
              resFs.on('end', () => {
                try {
                  if (resFs.statusCode === 200) {
                    const parsed = JSON.parse(dFs);
                    const tokens = [];
                    if (Array.isArray(parsed.documents)) {
                      for (const doc of parsed.documents) {
                        const tokenVal = doc.fields?.token?.stringValue;
                        if (tokenVal && tokenVal.length > 20) tokens.push(tokenVal);
                      }
                    }
                    resolve(tokens);
                  } else { resolve([]); }
                } catch (_) { resolve([]); }
              });
            });
            reqFs.on('error', () => resolve([]));
            reqFs.end();
          });

          const createPayload = (targetKey, targetVal) => ({
            message: {
              [targetKey]: targetVal,
              notification: {
                title: notif.title || 'OBIN Official Alert',
                body: notif.message || notif.desc || ''
              },
              data: {
                title: String(notif.title || 'OBIN Official Alert'),
                body: String(notif.message || notif.desc || ''),
                message: String(notif.message || notif.desc || ''),
                type: String(notif.type || 'general'),
                targetUrl: String(notif.targetUrl || notif.actionUrl || 'home'),
                actionUrl: String(notif.actionUrl || notif.targetUrl || 'home'),
                id: String(notif.id || `notif_${Date.now()}`),
                broadcastId: String(notif.broadcastId || `bc_${Date.now()}`),
                timestamp: String(notif.timestamp || Date.now()),
                imageUrl: String(notif.imageUrl || notif.extraUrl || '')
              },
              android: {
                priority: 'HIGH',
                notification: {
                  channel_id: 'mobinx_high_importance_channel',
                  notification_priority: 'PRIORITY_MAX',
                  default_sound: true,
                  default_vibrate_timings: true,
                  icon: 'ic_launcher',
                  color: '#1482FF',
                  click_action: 'FLUTTER_NOTIFICATION_CLICK',
                  visibility: 'PUBLIC'
                }
              }
            }
          });

          const sendOne = (targetKey, targetVal) => {
            const postStr = JSON.stringify(createPayload(targetKey, targetVal));
            return new Promise(resolve => {
              const reqMsg = https.request(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': `Bearer ${accessToken}`,
                  'Content-Length': Buffer.byteLength(postStr)
                }
              }, (resMsg) => {
                let rd = '';
                resMsg.on('data', c => { rd += c; });
                resMsg.on('end', () => { resolve({ target: targetVal, status: resMsg.statusCode, body: rd }); });
              });
              reqMsg.on('error', err => resolve({ target: targetVal, error: err.message }));
              reqMsg.write(postStr);
              reqMsg.end();
            });
          };

          const topicResults = await Promise.all(topics.map(topic => sendOne('topic', topic)));
          const tokenResults = await Promise.all(deviceTokens.map(tok => sendOne('token', tok)));
          const allResults = [...topicResults, ...tokenResults];

          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            success: true,
            protocol: 'fcm_v1',
            projectId,
            topicsDelivered: topicResults.filter(r => r.status === 200).length,
            tokensDelivered: tokenResults.filter(r => r.status === 200).length,
            totalDevicesTargeted: deviceTokens.length,
            results: allResults
          }));
          return;
        }

        // 2. Legacy Server Key fallback
        const serverKey = payload.serverKey || process.env.FCM_SERVER_KEY;
        if (serverKey) {
          const legacyPayload = {
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
              id: notif.id || `notif_${Date.now()}`,
              broadcastId: notif.broadcastId || `bc_${Date.now()}`
            }
          };

          const results = await Promise.all(topics.map(topic => {
            return new Promise(resolve => {
              const dataStr = JSON.stringify({ ...legacyPayload, to: `/topics/${topic}` });
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
              fcmReq.on('error', (err) => resolve({ topic, error: err.message }));
              fcmReq.write(dataStr);
              fcmReq.end();
            });
          }));

          res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
          res.end(JSON.stringify({ success: true, protocol: 'legacy_fcm', results }));
          return;
        }

        res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
        res.end(JSON.stringify({ success: false, protocol: 'none', message: 'No Service Account provided. Real-time Firestore sync active.' }));
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
