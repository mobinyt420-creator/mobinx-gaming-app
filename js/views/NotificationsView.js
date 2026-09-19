import { notificationService } from '../services/notificationService.js';
import { stateManager } from '../services/stateManager.js';
import { Toast } from '../components/Toast.js';

let activeNotifFilter = 'all';

export function renderNotificationsView() {
  const filters = ['all', 'tournament', 'topup', 'download', 'referral'];
  const items = notificationService.getByType(activeNotifFilter);

  const iconMap = {
    tournament: '🏆',
    topup: '💎',
    download: '📥',
    referral: '🎁'
  };

  return `
    <div class="view-container notifications-view">
      <div class="subview-header">
        <div class="subview-header-left">
          <button class="back-btn" id="btn-notif-back">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="15 18 9 12 15 6"></polyline></svg>
          </button>
          <h2 class="subview-title">Notifications</h2>
        </div>
        <button id="btn-mark-all-read" style="font-size: 11.5px; font-weight: 700; color: var(--primary);">
          Mark All Read
        </button>
      </div>

      <!-- Filter tabs -->
      <div class="filter-tabs-scroll">
        ${filters.map(f => `
          <button class="filter-tab-pill ${activeNotifFilter === f ? 'active' : ''}" data-notif-filter="${f}">
            ${f.charAt(0).toUpperCase() + f.slice(1)}
          </button>
        `).join('')}
      </div>

      <!-- Notification list -->
      <div class="notification-list">
        ${items.length === 0 ? `
          <div class="state-container">
            <div class="state-icon-circle">🔔</div>
            <h3 class="state-title">No notifications</h3>
            <p class="state-desc">You're all caught up! Match alerts and offers will appear here.</p>
          </div>
        ` : items.map(n => `
          <div class="notification-card ${n.unread ? 'unread' : ''}" data-notif-id="${n.id}" data-action-url="${n.actionUrl || n.targetUrl || ''}" style="cursor: pointer;">
            <div class="notification-icon-box" style="background: var(--bg-card-subtle);">
              <span style="font-size: 20px;">${iconMap[n.type] || '🔔'}</span>
            </div>
            <div style="flex: 1; min-width: 0;">
              <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 8px;">
                <h4 style="font-size: 13.5px; font-weight: 800; color: var(--text-main); line-height: 1.3;">${n.title}</h4>
                <span style="font-size: 10px; color: var(--text-muted); white-space: nowrap;">${n.timeAgo || n.time || 'Just now'}</span>
              </div>
              <p style="font-size: 11.5px; color: var(--text-secondary); margin-top: 3px; line-height: 1.4;">${n.desc || n.message || ''}</p>
              ${(n.actionUrl || n.targetUrl) ? `
                <div style="margin-top: 6px;">
                  <span style="font-size: 10.5px; font-weight: 800; color: var(--primary); display: inline-flex; align-items: center; gap: 4px;">
                    <span>View Details</span>
                    <span>→</span>
                  </span>
                </div>
              ` : ''}
            </div>
            ${n.unread ? `<div style="width: 7px; height: 7px; border-radius: 50%; background: var(--primary); margin-left: 6px; flex-shrink: 0; align-self: center;"></div>` : ''}
          </div>
        `).join('')}
      </div>
    </div>
  `;
}

export function bindNotificationsEvents() {
  document.getElementById('btn-notif-back')?.addEventListener('click', () => {
    stateManager.navigate('home');
  });

  document.querySelectorAll('[data-notif-filter]').forEach(pill => {
    pill.addEventListener('click', () => {
      activeNotifFilter = pill.getAttribute('data-notif-filter') || 'all';
      stateManager.navigate('notifications');
    });
  });

  document.getElementById('btn-mark-all-read')?.addEventListener('click', () => {
    notificationService.markAllAsRead();
    Toast.show('All notifications marked as read', 'success');
    stateManager.navigate('notifications');
  });

  document.querySelectorAll('.notification-card').forEach(card => {
    card.addEventListener('click', () => {
      const id = card.getAttribute('data-notif-id');
      const actionUrl = card.getAttribute('data-action-url');
      if (id) {
        notificationService.markAsRead(id);
        card.classList.remove('unread');
      }
      if (actionUrl) {
        if (typeof window.handleNotificationClick === 'function') {
          window.handleNotificationClick(actionUrl);
        } else if (actionUrl.startsWith('http')) {
          window.open(actionUrl, '_blank');
        } else {
          stateManager.navigate(actionUrl.replace('/', ''));
        }
      }
    });
  });
}
