import { firebaseService } from './firebaseService.js';
import { tournamentService } from './tournamentService.js';
import { downloadService } from './downloadService.js';
import { authService } from './authService.js';
import { stateManager } from './stateManager.js';
import { Toast } from '../components/Toast.js';

class RealtimeSyncManager {
  constructor() {
    this.isInitialized = false;
    this.unsubscribers = [];
  }

  init() {
    if (this.isInitialized || typeof window === 'undefined') return;
    this.isInitialized = true;

    // 1. Cross-tab / Local BroadcastChannel listener (Instant <10ms sync)
    firebaseService.onBroadcastMessage((msg) => {
      this.handleIncomingSync(msg.type, msg.payload, true);
    });

    // 2. Storage event listener (Fallback cross-tab sync)
    window.addEventListener('storage', (e) => {
      if (!e.key) return;
      if (e.key === 'mobinx_tournaments_data') {
        tournamentService.reloadFromStorage();
        this.triggerViewUpdate('tournaments');
      } else if (e.key === 'mobinx_downloads_catalog') {
        downloadService.reloadFromStorage();
        this.triggerViewUpdate('downloads');
      } else if (e.key === 'mobinx_hero_banners' || e.key === 'mobinx_flash_deals' || e.key === 'mobinx_popular_services') {
        this.triggerViewUpdate('home');
      }
    });

    // 3. Connect to Firestore Live Listeners (onSnapshot)
    this.initFirestoreRealtimeListeners();
  }

  async initFirestoreRealtimeListeners() {
    try {
      const fb = await firebaseService.init();
      if (!fb || !fb.db) return;

      console.log('⚡ Mobin X App: Connected to Real-Time Cloud Firestore Sync');

      // Live Tournaments Listener (Handles additions, updates, and deletions immediately)
      const unsubTournaments = await firebaseService.subscribeCollection('tournaments', (items) => {
        tournamentService.setAll(items || []);
        this.triggerViewUpdate('tournaments');
      });
      if (unsubTournaments) this.unsubscribers.push(unsubTournaments);

      // Live Downloads Listener
      const unsubDownloads = await firebaseService.subscribeCollection('downloads', (items) => {
        if (items) {
          downloadService.setCatalog(items);
          this.triggerViewUpdate('downloads');
        }
      });
      if (unsubDownloads) this.unsubscribers.push(unsubDownloads);

      // Live Banners Listener
      const unsubBanners = await firebaseService.subscribeCollection('banners', (items) => {
        if (items) {
          authService.saveHeroBanners(items);
          this.triggerViewUpdate('home');
        }
      });
      if (unsubBanners) this.unsubscribers.push(unsubBanners);

      // Live Flash Deals Listener
      const unsubDeals = await firebaseService.subscribeCollection('flashDeals', (items) => {
        if (items) {
          authService.saveFlashDeals(items);
          this.triggerViewUpdate('home');
        }
      });
      if (unsubDeals) this.unsubscribers.push(unsubDeals);

      // Live System Config & URLs
      const unsubConfig = await firebaseService.subscribeDocument('config', 'system', (data) => {
        if (data && data.urls) {
          authService.updateUrls(data.urls);
        }
      });
      if (unsubConfig) this.unsubscribers.push(unsubConfig);

      // Live Notices & Welcome Popup Listener
      const unsubNotices = await firebaseService.subscribeDocument('config', 'notices', (data) => {
        if (data) {
          if (data.welcomePopup && data.welcomePopup.enabled) {
            const dismissed = sessionStorage.getItem('mobinx_welcome_dismissed');
            if (!dismissed) {
              sessionStorage.setItem('mobinx_welcome_dismissed', 'true');
              stateManager.openModal('welcomeAnnouncement', data.welcomePopup);
            }
          }
          if (data.pushNotification && (!this.lastPushTime || data.pushNotification.timestamp > this.lastPushTime)) {
            this.lastPushTime = data.pushNotification.timestamp;
            Toast.show(`📢 ${data.pushNotification.message}`, 'info');
          }
        }
      });
      if (unsubNotices) this.unsubscribers.push(unsubNotices);

      // Live Home Notice Popup Listener (Screenshot Modal)
      const unsubHomePopup = await firebaseService.subscribeDocument('config', 'home_popup', (data) => {
        if (data) {
          authService.saveHomeNoticePopup(data);
          this.triggerViewUpdate('home');
        }
      });
      if (unsubHomePopup) this.unsubscribers.push(unsubHomePopup);

      // Live Google Play Store App Update Listener
      const unsubAppUpdate = await firebaseService.subscribeDocument('config', 'app_update', (data) => {
        if (data) {
          authService.saveAppUpdateConfig(data);
          this.triggerViewUpdate('home');
        }
      });
      if (unsubAppUpdate) this.unsubscribers.push(unsubAppUpdate);

    } catch (e) {
      console.warn('Real-time Firestore listener notice:', e.message);
    }
  }

  handleIncomingSync(type, payload, showNotice = false) {
    const currentView = stateManager.getState().currentView;

    switch (type) {
      case 'HOME_POPUP_UPDATED':
        if (payload) {
          authService.saveHomeNoticePopup(payload);
          this.triggerViewUpdate('home');
        }
        break;

      case 'APP_UPDATE_CONFIG_UPDATED':
        if (payload) {
          authService.saveAppUpdateConfig(payload);
          this.triggerViewUpdate('home');
        }
        break;

      case 'TOURNAMENTS_UPDATED':
        if (payload && payload.deletedId) {
          tournamentService.deleteTournament(payload.deletedId);
        } else {
          tournamentService.reloadFromStorage();
        }
        if (currentView === 'tournaments' || currentView === 'home') {
          stateManager.setState({ currentView });
        }
        break;

      case 'ROOM_RELEASED':
        tournamentService.reloadFromStorage();
        if (showNotice && type === 'ROOM_RELEASED') {
          Toast.show(`🔥 Room ID & Password released for: ${payload?.title || 'Tournament'}!`, 'success');
        }
        if (currentView === 'tournaments' || currentView === 'home') {
          stateManager.setState({ currentView });
        }
        break;

      case 'DOWNLOADS_UPDATED':
        downloadService.reloadFromStorage();
        if (currentView === 'downloads') {
          stateManager.setState({ currentView });
        }
        break;

      case 'BANNERS_UPDATED':
      case 'FLASH_DEALS_UPDATED':
      case 'SERVICES_UPDATED':
        if (currentView === 'home') {
          stateManager.setState({ currentView });
        }
        break;

      case 'URLS_UPDATED':
        if (payload) authService.updateUrls(payload);
        break;

      default:
        break;
    }
  }

  triggerViewUpdate(targetView) {
    const currentView = stateManager.getState().currentView;
    if (currentView === targetView || (targetView === 'home' && currentView === 'home')) {
      // Re-trigger render in current view
      stateManager.setState({ currentView });
    }
  }
}

export const realtimeSyncManager = new RealtimeSyncManager();
