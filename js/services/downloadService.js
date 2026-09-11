import { downloadItems } from '../data/mockData.js';
import { authService } from './authService.js';
import { firebaseService } from './firebaseService.js';

class DownloadService {
  constructor() {
    this.catalog = this.loadCatalog();
    this.activeDownloads = new Map();
    this.listeners = new Set();
  }

  loadCatalog() {
    if (typeof localStorage !== 'undefined') {
      const stored = localStorage.getItem('mobinx_downloads_catalog');
      if (stored) {
        try {
          const parsed = JSON.parse(stored);
          if (Array.isArray(parsed) && parsed.length > 0) {
            return this.sortList(parsed);
          }
        } catch (e) {}
      }
    }
    return this.sortList([...downloadItems]);
  }

  saveCatalog() {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_downloads_catalog', JSON.stringify(this.catalog));
    }
  }

  sortList(items) {
    if (!Array.isArray(items)) return [];
    return [...items].sort((a, b) => {
      // 1. Pinned items always stay on top
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      // 2. Explicit manual order index (0 = topmost)
      if (typeof a.order === 'number' && typeof b.order === 'number' && a.order !== b.order) {
        return a.order - b.order;
      }

      // 3. Fallback: Newest timestamp first
      const timeA = a.createdAt || a.timestamp || this.extractTimestamp(a.id);
      const timeB = b.createdAt || b.timestamp || this.extractTimestamp(b.id);
      return timeB - timeA;
    });
  }

  extractTimestamp(id) {
    if (!id) return 0;
    const digits = String(id).replace(/\D/g, '');
    if (digits.length >= 10) {
      return parseInt(digits.slice(0, 13), 10);
    }
    return 0;
  }

  getAll() {
    const active = this.catalog.filter(item => item.isActive !== false && item.status !== 'inactive');
    return this.sortList(active);
  }

  getRawCatalog() {
    return this.sortList(this.catalog);
  }

  setCatalog(items) {
    if (Array.isArray(items)) {
      this.catalog = this.sortList(items);
      this.saveCatalog();
      this.notify({ type: 'catalog_updated' });
    }
  }

  reloadFromStorage() {
    this.catalog = this.loadCatalog();
    this.notify({ type: 'catalog_updated' });
  }

  getByCategory(category) {
    const active = this.getAll();
    if (!category || category === 'All') return active;
    return active.filter(item => item.category && item.category.toLowerCase() === category.toLowerCase());
  }

  getById(id) {
    return this.catalog.find(item => item.id === id);
  }

  /**
   * Prepend new APK/Video item dynamically to the very top (Newest First)
   */
  async addItem(newItem) {
    const now = Date.now();
    const ytId = newItem.youtubeId || newItem.videoId || 'dQw4w9WgXcQ';
    
    // Generate clean formatted item
    const item = {
      id: `dl-${now}`,
      createdAt: now,
      timestamp: now,
      order: 0,
      rating: 5.0,
      downloadsCount: "1.2K",
      category: newItem.category || 'Mobin APK',
      title: newItem.title || 'New APK Download',
      youtubeId: ytId,
      videoId: ytId,
      videoThumbnail: newItem.videoThumbnail || `https://img.youtube.com/vi/${ytId}/hqdefault.jpg`,
      icon: newItem.icon || `https://img.youtube.com/vi/${ytId}/hqdefault.jpg`,
      videoDuration: newItem.videoDuration || '05:00',
      isPinned: newItem.isPinned || false,
      isActive: true,
      status: 'active',
      actionButtons: (newItem.actionButtons && newItem.actionButtons.length > 0) ? newItem.actionButtons : [
        { id: `act-1-${now}`, label: 'Download APK File', url: 'https://mrmobin.blogspot.com/', icon: 'download', type: 'direct' }
      ]
    };

    // Re-index existing items to be below the newly added one
    const updated = [item, ...this.catalog];
    updated.forEach((it, idx) => {
      it.order = idx;
    });

    this.catalog = updated;
    this.saveCatalog();
    this.notify({ type: 'catalog_updated' });

    // Sync to Firestore cloud
    try {
      if (firebaseService && typeof firebaseService.saveToFirestore === 'function') {
        await firebaseService.saveToFirestore('downloads', item.id, item);
      }
    } catch (e) {
      console.warn('Firestore sync error on addItem:', e);
    }

    return item;
  }

  async updateItem(id, updatedData) {
    const idx = this.catalog.findIndex(item => item.id === id);
    if (idx !== -1) {
      const ytId = updatedData.youtubeId || updatedData.videoId || this.catalog[idx].youtubeId || this.catalog[idx].videoId;
      const thumb = ytId ? `https://img.youtube.com/vi/${ytId}/hqdefault.jpg` : this.catalog[idx].videoThumbnail;

      this.catalog[idx] = {
        ...this.catalog[idx],
        ...updatedData,
        youtubeId: ytId,
        videoId: ytId,
        videoThumbnail: thumb,
        icon: thumb
      };

      this.saveCatalog();
      this.notify({ type: 'catalog_updated' });

      try {
        if (firebaseService && typeof firebaseService.saveToFirestore === 'function') {
          await firebaseService.saveToFirestore('downloads', id, this.catalog[idx]);
        }
      } catch (e) {
        console.warn('Firestore sync error on updateItem:', e);
      }
    }
  }

  async deleteItem(id) {
    this.catalog = this.catalog.filter(item => item.id !== id);
    // Re-index orders
    this.catalog.forEach((it, idx) => {
      it.order = idx;
    });
    this.saveCatalog();
    this.notify({ type: 'catalog_updated' });

    try {
      if (firebaseService && typeof firebaseService.deleteFromFirestore === 'function') {
        await firebaseService.deleteFromFirestore('downloads', id);
      }
    } catch (e) {
      console.warn('Firestore delete error on deleteItem:', e);
    }
  }

  /**
   * Move item UP or DOWN in ordering (Live Admin Adjustment)
   */
  async moveItem(id, direction) {
    const sorted = this.sortList([...this.catalog]);
    const index = sorted.findIndex(it => it.id === id);
    if (index === -1) return false;

    if (direction === 'up' && index > 0) {
      const temp = sorted[index];
      sorted[index] = sorted[index - 1];
      sorted[index - 1] = temp;
    } else if (direction === 'down' && index < sorted.length - 1) {
      const temp = sorted[index];
      sorted[index] = sorted[index + 1];
      sorted[index + 1] = temp;
    } else {
      return false; // Can't move further
    }

    // Update order numbers sequentially
    sorted.forEach((item, idx) => {
      item.order = idx;
    });

    this.catalog = sorted;
    this.saveCatalog();
    this.notify({ type: 'catalog_updated' });

    // Background sync updated orders to Firestore
    try {
      if (firebaseService && typeof firebaseService.saveToFirestore === 'function') {
        sorted.forEach(it => {
          firebaseService.saveToFirestore('downloads', it.id, it).catch(() => {});
        });
      }
    } catch (e) {}

    return true;
  }

  startDownload(itemId, onProgress, onComplete) {
    const item = this.getById(itemId);
    if (!item) return;

    if (this.activeDownloads.has(itemId)) {
      clearInterval(this.activeDownloads.get(itemId).timer);
    }

    let progress = 0;
    const downloadState = {
      id: itemId,
      item,
      progress: 0,
      status: 'downloading'
    };

    const timer = setInterval(() => {
      progress += Math.floor(Math.random() * 15) + 12;
      if (progress >= 100) {
        progress = 100;
        clearInterval(timer);
        downloadState.status = 'completed';
        downloadState.progress = 100;
        authService.recordDownload(itemId);
        if (onComplete) onComplete(item);
      } else {
        downloadState.progress = progress;
        if (onProgress) onProgress(progress);
      }
      this.notify(downloadState);
    }, 250);

    downloadState.timer = timer;
    this.activeDownloads.set(itemId, downloadState);
    return downloadState;
  }

  cancelDownload(itemId) {
    if (this.activeDownloads.has(itemId)) {
      clearInterval(this.activeDownloads.get(itemId).timer);
      this.activeDownloads.delete(itemId);
      this.notify({ id: itemId, status: 'cancelled', progress: 0 });
    }
  }

  subscribe(listener) {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  notify(state) {
    for (const listener of this.listeners) {
      listener(state);
    }
  }
}

export const downloadService = new DownloadService();
