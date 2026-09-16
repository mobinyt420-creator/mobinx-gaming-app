import { stateManager } from '../services/stateManager.js';
import { authService } from '../services/authService.js';
import { notificationService } from '../services/notificationService.js';

export function renderHeader() {
  const user = authService.getCurrentUser();
  const unreadCount = notificationService.getUnreadCount() || 3;

  return `
    <header class="app-header">
      <div class="header-left">
        <button class="header-btn" id="btn-hamburger-menu" title="Menu" aria-label="Open navigation drawer">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round">
            <line x1="3" y1="6" x2="21" y2="6"></line>
            <line x1="3" y1="12" x2="21" y2="12"></line>
            <line x1="3" y1="18" x2="21" y2="18"></line>
          </svg>
        </button>
        
        <div class="app-brand" id="brand-home-trigger" title="OBIN Home">
          <div class="brand-logo-icon" style="width: 28px; height: 28px; border-radius: 8px; overflow: hidden; display: flex; align-items: center; justify-content: center; border: 1px solid rgba(56, 189, 248, 0.4); box-shadow: 0 2px 8px rgba(2, 132, 199, 0.3);">
            <img src="assets/images/obin_icon_512.png" alt="OBIN" style="width: 100%; height: 100%; object-fit: cover;" />
          </div>
          <div class="brand-text">
            <span class="brand-title" style="font-weight: 900; letter-spacing: 0.5px;">OBIN</span>
          </div>
        </div>
      </div>

      <div class="header-right">
        <button class="header-btn" id="btn-header-notif" title="Notifications" aria-label="Notifications">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
            <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
          </svg>
          <span class="notification-badge">${unreadCount}</span>
        </button>

        <div class="header-avatar" id="btn-header-profile" title="My Profile">
          <img src="${user.avatar && !user.avatar.includes('dicebear') ? user.avatar : 'data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 64 64\'><circle cx=\'32\' cy=\'32\' r=\'32\' fill=\'%231e293b\'/><circle cx=\'32\' cy=\'24\' r=\'12\' fill=\'%233b82f6\'/><path d=\'M14 52c0-10 8-18 18-18s18 8 18 18\' fill=\'%232563eb\'/></svg>'}" alt="${user.username || 'Player'}" referrerpolicy="no-referrer" onerror="this.onerror=null;this.src='data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 64 64\'><circle cx=\'32\' cy=\'32\' r=\'32\' fill=\'%231e293b\'/><circle cx=\'32\' cy=\'24\' r=\'12\' fill=\'%233b82f6\'/><path d=\'M14 52c0-10 8-18 18-18s18 8 18 18\' fill=\'%232563eb\'/></svg>';" />
        </div>
      </div>
    </header>
  `;
}

export function bindHeaderEvents() {
  document.getElementById('btn-hamburger-menu')?.addEventListener('click', () => {
    stateManager.toggleDrawer();
  });

  document.getElementById('brand-home-trigger')?.addEventListener('click', () => {
    stateManager.navigate('home');
  });

  document.getElementById('btn-header-notif')?.addEventListener('click', () => {
    stateManager.navigate('notifications');
  });

  document.getElementById('btn-header-profile')?.addEventListener('click', () => {
    stateManager.navigate('profile');
  });
}
