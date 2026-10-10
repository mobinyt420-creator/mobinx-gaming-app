import fs from 'fs';
import path from 'path';
import http from 'http';
import { fileURLToPath } from 'url';
import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 1. CONFIGURATION
const TELEGRAM_BOT_TOKEN = '8537209054:AAHcWYhvYnaWAAy1q-Ddfqeo68-v4dKyR-g';
const TELEGRAM_GROUP_ID = '-1003998990977';
const GOOGLE_SHEET_URL = 'https://script.google.com/macros/s/AKfycbyTNy4-vp95IvaYyPKtB0LxkfqJICjzphTNCjs4aOBo8zA1Qn2bIJGHNUvjNGST1d8/exec';

const POSSIBLE_SA_PATHS = [
  path.resolve(__dirname, '../scratch/fcm_service_account.json'),
  path.resolve(__dirname, 'fcm_service_account.json'),
  path.resolve(__dirname, '../fcm_service_account.json')
];

const PRIMARY_CACHE_PATH = path.resolve(__dirname, 'notified_users.json');
const FALLBACK_CACHE_PATH = path.resolve(__dirname, '../scratch/notified_users.json');

// Helper: Safe HTML Escaping for Telegram
export function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

// Helper: 12-Hour AM/PM Time Formatter (Bangladeshi Standard)
export function formatOBINDateTime(dateInput) {
  let d;
  if (dateInput && typeof dateInput.toDate === 'function') {
    d = dateInput.toDate();
  } else if (dateInput && typeof dateInput.seconds === 'number') {
    d = new Date(dateInput.seconds * 1000);
  } else if (dateInput && dateInput !== 'Today') {
    d = new Date(dateInput);
  } else {
    d = new Date();
  }
  if (isNaN(d.getTime())) d = new Date();

  const day = String(d.getDate()).padStart(2, '0');
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const month = months[d.getMonth()];
  const year = d.getFullYear();

  let hours = d.getHours();
  const minutes = String(d.getMinutes()).padStart(2, '0');
  const ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours ? hours : 12;
  const strHours = String(hours).padStart(2, '0');

  return `${day} ${month} ${year}, ${strHours}:${minutes} ${ampm}`;
}

// Helper: Send Telegram Alert with Serial Number & Rate-Limit Handling
export async function sendTelegramAlert(user) {
  const serialTag = user.serial ? ` (#${user.serial})` : '';
  const serialLine = user.serial ? `🔢 <b>Gamer Serial:</b> #${user.serial}\n` : '';
  const safeName = escapeHtml(user.name || 'Gamer');
  const safeEmail = escapeHtml(user.email || 'N/A');
  const safePhone = escapeHtml(user.phone || 'N/A');
  const safeFfUid = escapeHtml(user.ffUid || 'None');
  const safeTime = escapeHtml(user.time || '');

  const text = `🔔 <b>New Gamer Registered on OBIN!${serialTag}</b>\n━━━━━━━━━━━━━━━━━━━━\n👤 <b>Name:</b> ${safeName}\n📧 <b>Gmail:</b> ${safeEmail}\n📱 <b>Phone:</b> ${safePhone}\n🎮 <b>FF UID:</b> ${safeFfUid}\n${serialLine}⏰ <b>Date & Time:</b> ${safeTime}\n━━━━━━━━━━━━━━━━━━━━\n⚡ <i>OBIN Automated Cloud System</i>`;

  for (let attempt = 0; attempt < 4; attempt++) {
    try {
      const res = await fetch(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          chat_id: TELEGRAM_GROUP_ID,
          text: text,
          parse_mode: 'HTML'
        }),
        signal: AbortSignal.timeout(10000)
      });
      const data = await res.json();
      if (data.ok) {
        return true;
      }
      if (data.error_code === 429) {
        const waitSec = (data.parameters?.retry_after || 4) + 1;
        console.warn(`[Telegram] Rate limited (429). Pausing ${waitSec}s before retry...`);
        await new Promise(r => setTimeout(r, waitSec * 1000));
        continue;
      }
      console.warn(`[Telegram] Alert warning:`, data.description);
      return false;
    } catch (err) {
      console.error(`[Telegram] Network error (attempt ${attempt + 1}):`, err.message);
      await new Promise(r => setTimeout(r, 2000));
    }
  }
  return false;
}

// Helper: Send to Google Sheet (text/plain with 15s timeout)
export async function sendToGoogleSheet(user) {
  let phone = String(user.phone || '').trim();
  if (phone && !phone.startsWith('0') && !phone.startsWith('+') && phone.length === 10) {
    phone = '0' + phone;
  }
  const sheetPhone = phone ? "'" + phone : '';

  const payload = {
    serial: user.serial || '',
    time: user.time,
    name: user.name || 'Gamer',
    email: user.email || '',
    phone: sheetPhone,
    ffUid: user.ffUid || 'None',
    status: user.status || 'Active'
  };

  try {
    const res = await fetch(GOOGLE_SHEET_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'text/plain;charset=utf-8' },
      body: JSON.stringify(payload),
      signal: AbortSignal.timeout(15000)
    });
    const text = await res.text();
    return text.includes('success');
  } catch (err) {
    console.warn(`[GoogleSheet] Sync notice:`, err.message);
    return false;
  }
}

// 2. PERSISTENCE FOR NOTIFIED USERS
function loadNotifiedSet() {
  for (const cacheFile of [PRIMARY_CACHE_PATH, FALLBACK_CACHE_PATH]) {
    try {
      if (fs.existsSync(cacheFile)) {
        const arr = JSON.parse(fs.readFileSync(cacheFile, 'utf8'));
        if (Array.isArray(arr) && arr.length > 0) {
          return new Set(arr);
        }
      }
    } catch (_) {}
  }
  return new Set();
}

function saveNotifiedSet(notifiedSet) {
  const data = JSON.stringify(Array.from(notifiedSet), null, 2);
  try {
    fs.writeFileSync(PRIMARY_CACHE_PATH, data, 'utf8');
  } catch (_) {}
  try {
    fs.writeFileSync(FALLBACK_CACHE_PATH, data, 'utf8');
  } catch (_) {}
}

// 3. START REAL-TIME FIRESTORE LISTENER
let isRunning = false;
let notifiedSet = loadNotifiedSet();

export async function startObinCloudSync() {
  if (isRunning) {
    console.log('[CloudSync] Already running.');
    return;
  }
  isRunning = true;

  console.log('🚀 Starting OBIN Real-Time Cloud Sync (Telegram & Google Sheet)...');

  let serviceAccount = null;
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    let val = String(process.env.FIREBASE_SERVICE_ACCOUNT).trim();
    try {
      serviceAccount = JSON.parse(val);
    } catch (_) {
      try {
        serviceAccount = JSON.parse(Buffer.from(val, 'base64').toString('utf8'));
      } catch (_) {}
    }
  }

  if (!serviceAccount) {
    for (const p of POSSIBLE_SA_PATHS) {
      if (fs.existsSync(p)) {
        try {
          serviceAccount = JSON.parse(fs.readFileSync(p, 'utf8'));
          break;
        } catch (_) {}
      }
    }
  }

  if (!serviceAccount) {
    console.error('❌ Service account not found in env or files:', POSSIBLE_SA_PATHS);
    isRunning = false;
    return;
  }

  let app;
  const existingApps = getApps();
  const found = existingApps.find(a => a.name === 'obin-sync-engine');
  if (found) {
    app = found;
  } else {
    app = initializeApp({
      credential: cert(serviceAccount)
    }, 'obin-sync-engine');
  }

  const db = getFirestore(app);

  // Sync memory set with Firestore cloud backup
  try {
    const syncDoc = await db.collection('system_sync').doc('telegram_sheet').get();
    if (syncDoc.exists) {
      const data = syncDoc.data() || {};
      if (Array.isArray(data.syncedIds)) {
        data.syncedIds.forEach(id => notifiedSet.add(id));
      }
    }
  } catch (_) {}

  saveNotifiedSet(notifiedSet);
  console.log(`📋 Cache loaded: ${notifiedSet.size} users already indexed.`);

  let isFirstBatch = true;

  db.collection('users').onSnapshot(async (snapshot) => {
    if (isFirstBatch) {
      isFirstBatch = false;
      console.log(`🔍 Initial check: ${snapshot.size} users exist in Firestore.`);

      // Find any users who registered while offline
      const missingUsers = [];
      snapshot.forEach(doc => {
        const data = doc.data();
        if (!notifiedSet.has(doc.id) && !data.telegramSynced) {
          missingUsers.push({
            id: doc.id,
            name: data.name || data.fullName || 'New Gamer',
            email: data.email || 'N/A',
            phone: data.phone || 'N/A',
            ffUid: data.ffUid || 'None',
            status: data.status || 'Active',
            time: formatOBINDateTime(data.registeredAtIso || data.registeredDate || new Date())
          });
        }
      });

      const updateCloudSyncDoc = async () => {
        try {
          await db.collection('system_sync').doc('telegram_sheet').set({
            lastUpdated: new Date().toISOString(),
            syncedCount: notifiedSet.size,
            syncedIds: Array.from(notifiedSet)
          }, { merge: true });
        } catch (_) {}
      };

      if (missingUsers.length > 0) {
        console.log(`⚡ Found ${missingUsers.length} unnotified users who registered while offline! Syncing now...`);
        let processedCount = 0;
        for (const userObj of missingUsers) {
          const serial = notifiedSet.size + 1;
          userObj.serial = serial;
          console.log(`🔔 [BACKLOG SYNC #${serial}]: ${userObj.name} (${userObj.email}) | Phone: ${userObj.phone}`);
          await Promise.allSettled([
            sendTelegramAlert(userObj),
            sendToGoogleSheet(userObj)
          ]);
          notifiedSet.add(userObj.id);
          saveNotifiedSet(notifiedSet);
          // Mark in Firestore
          db.collection('users').doc(userObj.id).set({ telegramSynced: true, gamerSerial: serial }, { merge: true }).catch(() => {});
          
          processedCount++;
          if (processedCount % 10 === 0) {
            await updateCloudSyncDoc();
          }
          await new Promise(r => setTimeout(r, 1200));
        }
        await updateCloudSyncDoc();
        console.log(`✅ All ${missingUsers.length} backlog users synced successfully!`);
      } else {
        console.log(`✅ All ${snapshot.size} users are up to date.`);
      }

      console.log(`📡 Real-time listener active. Watching for NEW users...`);
      return;
    }

    // Process doc changes for newly added users in real-time
    for (const change of snapshot.docChanges()) {
      if (change.type === 'added' || change.type === 'modified') {
        const doc = change.doc;
        const id = doc.id;
        const data = doc.data();

        if (!notifiedSet.has(id) && !data.telegramSynced) {
          let serial = data.gamerSerial;
          if (!serial) {
            try {
              const countSnap = await db.collection('users').count().get();
              serial = countSnap.data().count;
            } catch (_) {
              serial = notifiedSet.size + 1;
            }
          }
          notifiedSet.add(id);
          saveNotifiedSet(notifiedSet);

          const userObj = {
            id,
            serial,
            name: data.name || data.fullName || 'New Gamer',
            email: data.email || 'N/A',
            phone: data.phone || 'N/A',
            ffUid: data.ffUid || 'None',
            status: data.status || 'Active',
            time: formatOBINDateTime(data.registeredAtIso || data.registeredDate || new Date())
          };

          console.log(`🔔 [REAL-TIME USER #${serial}]: ${userObj.name} (${userObj.email}) | Phone: ${userObj.phone}`);
          await Promise.allSettled([
            sendTelegramAlert(userObj),
            sendToGoogleSheet(userObj)
          ]);

          // Mark in Firestore
          db.collection('users').doc(id).set({ telegramSynced: true, gamerSerial: serial }, { merge: true }).catch(() => {});
          
          try {
            await db.collection('system_sync').doc('telegram_sheet').set({
              lastUpdated: new Date().toISOString(),
              syncedCount: notifiedSet.size,
              syncedIds: Array.from(notifiedSet)
            }, { merge: true });
          } catch (_) {}
        }
      }
    }
  }, (err) => {
    console.error('❌ Firestore listener error:', err.message);
    isRunning = false;
    setTimeout(() => {
      console.log('🔄 Reconnecting Firestore listener...');
      startObinCloudSync().catch(console.error);
    }, 10000);
  });
}

// 4. EMBEDDED HTTP SERVER FOR 24/7 CLOUD HOSTING & HEALTH CHECKS
if (process.argv[1] === fileURLToPath(import.meta.url) && process.env.PORT) {
  const HTTP_PORT = process.env.PORT || 8080;
  const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'online',
      service: 'OBIN Real-Time Cloud Sync Daemon',
      telegramBot: '@OBIN_USER_Bot',
      channel: 'OBIN_USER_GR',
      indexedUsers: notifiedSet.size,
      timestamp: new Date().toISOString()
    }));
  });
  server.listen(HTTP_PORT, '0.0.0.0', () => {
    console.log(`🌐 Cloud Health server active on port ${HTTP_PORT}`);
  });
}

// Copy to scratch for sync
try {
  const scratchSync = path.resolve(__dirname, '../scratch/obin_cloud_sync.mjs');
  fs.copyFileSync(__filename, scratchSync);
} catch (_) {}

// Start if executed directly
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  startObinCloudSync().catch(console.error);
}
