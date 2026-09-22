import https from 'https';

export default async function handler(req, res) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const payload = typeof req.body === 'string' ? JSON.parse(req.body || '{}') : (req.body || {});
    const serverKey = payload.serverKey || process.env.FCM_SERVER_KEY;
    const notif = payload.notification || payload;

    if (!serverKey) {
      return res.status(200).json({
        success: false,
        message: 'FCM Server Key not provided. Set key in Admin Panel or FCM_SERVER_KEY env.'
      });
    }

    const topics = ['all', 'all_users', 'mobinx_broadcast', 'obin_broadcast'];
    const fcmPayload = {
      priority: 'high',
      notification: {
        title: notif.title || 'OBIN Announcement',
        body: notif.message || notif.desc || '',
        sound: 'default',
        android_channel_id: 'mobinx_high_importance_channel',
        channel_id: 'mobinx_push_channel',
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

    const results = await Promise.all(
      topics.map(topic => {
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
      })
    );

    return res.status(200).json({ success: true, results });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
}
