import { firebaseConfig } from './firebaseConfig.js';

let app = null;
let auth = null;
let db = null;
let googleProvider = null;
let isFirebaseInitialized = false;

// Initialize Firebase in browser environment
export async function initFirebase() {
  if (typeof window === 'undefined') return null;
  if (isFirebaseInitialized) return { app, auth, db, googleProvider };

  try {
    const { initializeApp } = await import('https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js');
    const { getAuth, GoogleAuthProvider } = await import('https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js');
    const { getFirestore } = await import('https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js');

    app = initializeApp(firebaseConfig);
    auth = getAuth(app);
    googleProvider = new GoogleAuthProvider();
    googleProvider.setCustomParameters({ prompt: 'select_account' });
    db = getFirestore(app);

    isFirebaseInitialized = true;
    console.log('⚡ Firebase Initialized Successfully with Project:', firebaseConfig.projectId);
    return { app, auth, db, googleProvider };
  } catch (error) {
    console.warn('Firebase CDN initialization notice:', error.message);
    return null;
  }
}

// Google Sign-In with real Popup
export async function signInWithGoogleFirebase() {
  if (!isFirebaseInitialized) {
    await initFirebase();
  }

  if (!auth || !googleProvider) {
    console.log('Firebase Auth fallback active');
    return null;
  }

  try {
    const { signInWithPopup } = await import('https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js');
    const result = await signInWithPopup(auth, googleProvider);
    const user = result.user;
    return {
      uid: user.uid,
      displayName: user.displayName || 'Gamer',
      email: user.email,
      photoURL: user.photoURL || 'assets/images/avatar_user.jpg',
      phoneNumber: user.phoneNumber || ''
    };
  } catch (error) {
    console.error('Google Sign-In Error:', error);
    throw error;
  }
}

// Save or sync document in Firestore
export async function saveToFirestore(collectionName, docId, data) {
  if (!isFirebaseInitialized) await initFirebase();
  if (!db) return false;

  try {
    const { doc, setDoc } = await import('https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js');
    await setDoc(doc(db, collectionName, docId), data, { merge: true });
    return true;
  } catch (err) {
    console.warn(`Firestore save error in ${collectionName}:`, err.message);
    return false;
  }
}

// Fetch documents from a collection in Firestore
export async function getFromFirestore(collectionName) {
  if (!isFirebaseInitialized) await initFirebase();
  if (!db) return null;

  try {
    const { collection, getDocs } = await import('https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js');
    const querySnapshot = await getDocs(collection(db, collectionName));
    const items = [];
    querySnapshot.forEach(doc => {
      items.push({ id: doc.id, ...doc.data() });
    });
    return items;
  } catch (err) {
    console.warn(`Firestore read error in ${collectionName}:`, err.message);
    return null;
  }
}

// Real-Time Listener for a Collection (Firestore onSnapshot)
export async function subscribeToCollection(collectionName, callback) {
  if (!isFirebaseInitialized) await initFirebase();
  if (!db) return null;

  try {
    const { collection, onSnapshot } = await import('https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js');
    const unsubscribe = onSnapshot(collection(db, collectionName), (snapshot) => {
      const items = [];
      snapshot.forEach(doc => items.push({ id: doc.id, ...doc.data() }));
      callback(items);
    }, (err) => {
      console.warn(`Firestore onSnapshot error on [${collectionName}]:`, err.message);
    });
    return unsubscribe;
  } catch (err) {
    console.warn(`Could not set up onSnapshot for ${collectionName}:`, err.message);
    return null;
  }
}

// Real-Time Listener for a Single Document (e.g. settings/notices)
export async function subscribeToDocument(collectionName, docId, callback) {
  if (!isFirebaseInitialized) await initFirebase();
  if (!db) return null;

  try {
    const { doc, onSnapshot } = await import('https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js');
    const unsubscribe = onSnapshot(doc(db, collectionName, docId), (docSnap) => {
      if (docSnap.exists()) {
        callback({ id: docSnap.id, ...docSnap.data() });
      }
    }, (err) => {
      console.warn(`Firestore doc onSnapshot error [${collectionName}/${docId}]:`, err.message);
    });
    return unsubscribe;
  } catch (err) {
    console.warn(`Could not set up onSnapshot doc for ${collectionName}/${docId}:`, err.message);
    return null;
  }
}

// Real-time Event Bus for zero-latency local & cross-tab synchronization
let realtimeChannel = null;
try {
  if (typeof window !== 'undefined' && 'BroadcastChannel' in window) {
    realtimeChannel = new BroadcastChannel('mobinx_realtime_sync');
  }
} catch (e) {
  console.warn('BroadcastChannel not supported:', e.message);
}

export function broadcastChange(type, payload) {
  if (realtimeChannel) {
    try {
      realtimeChannel.postMessage({ type, payload, timestamp: Date.now() });
    } catch (e) {
      console.warn('broadcast error:', e);
    }
  }
}

export function onBroadcastMessage(callback) {
  if (realtimeChannel) {
    realtimeChannel.onmessage = (event) => {
      if (event && event.data) callback(event.data);
    };
  }
}

export const firebaseService = {
  init: initFirebase,
  signInWithGoogle: signInWithGoogleFirebase,
  saveDocument: saveToFirestore,
  getCollection: getFromFirestore,
  subscribeCollection: subscribeToCollection,
  subscribeDocument: subscribeToDocument,
  broadcastChange,
  onBroadcastMessage
};

