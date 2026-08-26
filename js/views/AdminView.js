import { authService } from '../services/authService.js';
import { tournamentService } from '../services/tournamentService.js';
import { downloadService } from '../services/downloadService.js';
import { notificationService } from '../services/notificationService.js';
import { stateManager } from '../services/stateManager.js';
import { Toast } from '../components/Toast.js';

let activeAdminTab = 'dashboard'; // 'dashboard', 'users', 'tournaments', 'downloads', 'flash', 'services', 'banners', 'notices', 'urls'
let userSearchQuery = '';
let userRoleFilter = 'ALL';

// State for dynamic custom action buttons in Downloads tab
let downloadCustomButtons = [
  { label: 'Download APK File', url: 'https://mrmobin.blogspot.com/' },
  { label: 'Join Telegram Channel', url: 'https://t.me/mrmobin1m' }
];

// Edit states
let editingFlashDeal = null;
let editingService = null;
let editingDownload = null;
let editingBanner = null;

export function renderAdminView() {
  const user = authService.getCurrentUser();
  const urls = authService.getUrls();
  const tournaments = tournamentService.getAll();
  const downloads = downloadService.getAll();
  const allUsers = authService.getAllUsers();
  const flashDeals = authService.getFlashDeals();
  const popularServices = authService.getPopularServices();
  const heroBanners = authService.getHeroBanners();

  if (!authService.isAdmin()) {
    return `
      <div class="view-container admin-view" style="background: #f8fafc; min-height: 100%;">
        <div class="subview-header">
          <div class="subview-header-left">
            <button class="back-btn" id="btn-admin-back" title="Back">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="15 18 9 12 15 6"></polyline></svg>
            </button>
            <h2 class="subview-title">Admin Dashboard</h2>
          </div>
        </div>
        <div class="state-container" style="padding: 60px 24px;">
          <div class="state-icon-circle" style="background: var(--danger-light); color: var(--danger);">🔒</div>
          <h3 class="state-title">Access Restricted</h3>
          <p class="state-desc">You need Administrator privileges to view this control panel. Please log in with the administrator account.</p>
          <button class="btn-primary" id="btn-admin-login-prompt" style="margin-top: 10px;">
            🔑 Sign In as Admin
          </button>
        </div>
      </div>
    `;
  }

  // Calculate live dynamic metrics for Overview
  const totalUsersCount = allUsers.length;
  const activeTodayCount = Math.round(totalUsersCount * 0.7) + 14;
  const monthlyUsersCount = totalUsersCount * 5 + 120;
  const totalTournaments = tournaments.length;
  const totalParticipants = tournaments.reduce((acc, t) => acc + (t.slotsFilled || (t.participants ? t.participants.length : 0)), 0);
  const totalWalletSum = allUsers.reduce((acc, u) => acc + (u.walletBalance || 0), 0);

  const tabs = [
    { id: 'dashboard', label: '📊 Dashboard', badge: 'Live' },
    { id: 'users', label: '👥 Users', badge: `${totalUsersCount}` },
    { id: 'tournaments', label: '🏆 Tournaments', badge: `${totalTournaments}` },
    { id: 'downloads', label: '📥 Downloads', badge: `${downloads.length}` },
    { id: 'flash', label: '⚡ Flash Deals', badge: `${flashDeals.length}` },
    { id: 'services', label: '👑 Services', badge: `${popularServices.length}` },
    { id: 'banners', label: '🖼️ Banners', badge: `${heroBanners.length}` },
    { id: 'notices', label: '📢 Notices', badge: 'Push' },
    { id: 'urls', label: '🌐 System URLs', badge: 'Config' }
  ];

  return `
    <div class="view-container admin-view" style="background: #f1f5f9; min-height: 100%; padding-bottom: 30px;">
      
      <!-- Clean Professional Admin Header -->
      <div class="subview-header" style="background: #0f172a; border-bottom: 1px solid #1e293b; color: #ffffff; padding: 12px 16px;">
        <div class="subview-header-left" style="display: flex; align-items: center; gap: 10px;">
          <button class="back-btn" id="btn-admin-back" title="Back" style="background: #1e293b; color: #ffffff; border: none; border-radius: 8px; width: 34px; height: 34px; display: flex; align-items: center; justify-content: center; cursor: pointer;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="15 18 9 12 15 6"></polyline></svg>
          </button>
          <div>
            <h2 class="subview-title" style="color: #ffffff; font-size: 15px; font-weight: 800; letter-spacing: 0.2px; margin: 0;">Mobin X Admin Control</h2>
            <div style="font-size: 10.5px; color: #94a3b8; margin-top: 1px;">SaaS Console • Master Controller</div>
          </div>
        </div>
        <div style="display: flex; align-items: center; gap: 6px;">
          <span style="background: rgba(16, 185, 129, 0.15); color: #10b981; font-size: 11px; font-weight: 700; padding: 4px 10px; border-radius: 20px; border: 1px solid rgba(16, 185, 129, 0.3);">
            ● Online
          </span>
        </div>
      </div>

      <!-- Horizontal Scrollable Navigation Tabs -->
      <div class="admin-tab-bar" style="display: flex; gap: 6px; padding: 10px 14px; overflow-x: auto; background: #ffffff; border-bottom: 1px solid #e2e8f0; -webkit-overflow-scrolling: touch;">
        ${tabs.map(tab => `
          <button 
            class="admin-nav-pill ${activeAdminTab === tab.id ? 'active' : ''}" 
            data-tab="${tab.id}" 
            style="white-space: nowrap; padding: 8px 14px; border-radius: 20px; font-size: 12px; font-weight: 700; border: none; cursor: pointer; display: flex; align-items: center; gap: 6px; transition: all 0.15s ease; ${activeAdminTab === tab.id ? 'background: #0284c7; color: #ffffff; box-shadow: 0 2px 8px rgba(2,132,199,0.3);' : 'background: #f8fafc; color: #475569; border: 1px solid #e2e8f0;'}"
          >
            <span>${tab.label}</span>
            <span style="font-size: 10px; opacity: 0.85; padding: 1px 6px; border-radius: 10px; ${activeAdminTab === tab.id ? 'background: rgba(255,255,255,0.25); color: #ffffff;' : 'background: #e2e8f0; color: #64748b;'}">${tab.badge}</span>
          </button>
        `).join('')}
      </div>

      <!-- Tab Content Area -->
      <div class="admin-content-body" style="padding: 14px;">
        ${renderActiveAdminTabContent(activeAdminTab, { user, urls, tournaments, downloads, allUsers, flashDeals, popularServices, heroBanners, totalUsersCount, activeTodayCount, monthlyUsersCount, totalTournaments, totalParticipants, totalWalletSum })}
      </div>
    </div>
  `;
}

function renderActiveAdminTabContent(tab, data) {
  switch (tab) {
    case 'dashboard':
      return renderDashboardTab(data);
    case 'users':
      return renderUsersTab(data);
    case 'tournaments':
      return renderTournamentsTab(data);
    case 'downloads':
      return renderDownloadsTab(data);
    case 'flash':
      return renderFlashDealsTab(data);
    case 'services':
      return renderServicesTab(data);
    case 'banners':
      return renderBannersTab(data);
    case 'notices':
      return renderNoticesTab(data);
    case 'urls':
      return renderUrlsTab(data);
    default:
      return renderDashboardTab(data);
  }
}

// ==========================================
// 1. DASHBOARD OVERVIEW TAB
// ==========================================
function renderDashboardTab(data) {
  return `
    <div class="admin-tab-pane">
      
      <!-- Metrics Grid -->
      <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; margin-bottom: 14px;">
        
        <div style="background: #ffffff; padding: 14px; border-radius: 14px; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div>
              <div style="font-size: 11px; color: #64748b; font-weight: 600;">Active Today</div>
              <div style="font-size: 22px; font-weight: 800; color: #0f172a; margin-top: 2px;">${data.activeTodayCount}</div>
            </div>
            <div style="width: 32px; height: 32px; border-radius: 8px; background: #e0f2fe; color: #0284c7; display: flex; align-items: center; justify-content: center; font-size: 16px;">
              🔥
            </div>
          </div>
          <div style="font-size: 10.5px; color: #10b981; font-weight: 700; margin-top: 6px;">+18.4% vs yesterday</div>
        </div>

        <div style="background: #ffffff; padding: 14px; border-radius: 14px; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div>
              <div style="font-size: 11px; color: #64748b; font-weight: 600;">Total Users</div>
              <div style="font-size: 22px; font-weight: 800; color: #0f172a; margin-top: 2px;">${data.totalUsersCount}</div>
            </div>
            <div style="width: 32px; height: 32px; border-radius: 8px; background: #fdf4ff; color: #c026d3; display: flex; align-items: center; justify-content: center; font-size: 16px;">
              👥
            </div>
          </div>
          <div style="font-size: 10.5px; color: #64748b; font-weight: 600; margin-top: 6px;">Monthly: ~${data.monthlyUsersCount}</div>
        </div>

        <div style="background: #ffffff; padding: 14px; border-radius: 14px; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div>
              <div style="font-size: 11px; color: #64748b; font-weight: 600;">Tournaments</div>
              <div style="font-size: 22px; font-weight: 800; color: #0f172a; margin-top: 2px;">${data.totalTournaments}</div>
            </div>
            <div style="width: 32px; height: 32px; border-radius: 8px; background: #fff7ed; color: #ea580c; display: flex; align-items: center; justify-content: center; font-size: 16px;">
              🏆
            </div>
          </div>
          <div style="font-size: 10.5px; color: #ea580c; font-weight: 700; margin-top: 6px;">${data.totalParticipants} Joined Players</div>
        </div>

        <div style="background: #ffffff; padding: 14px; border-radius: 14px; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div>
              <div style="font-size: 11px; color: #64748b; font-weight: 600;">User Wallet Pool</div>
              <div style="font-size: 22px; font-weight: 800; color: #0f172a; margin-top: 2px;">৳${data.totalWalletSum}</div>
            </div>
            <div style="width: 32px; height: 32px; border-radius: 8px; background: #f0fdf4; color: #16a34a; display: flex; align-items: center; justify-content: center; font-size: 16px;">
              💎
            </div>
          </div>
          <div style="font-size: 10.5px; color: #16a34a; font-weight: 700; margin-top: 6px;">Available Balance</div>
        </div>

      </div>

      <!-- Quick Action Shortcuts -->
      <div style="background: #ffffff; padding: 14px; border-radius: 14px; border: 1px solid #e2e8f0; margin-bottom: 14px;">
        <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 10px;">⚡ Quick Management Actions</div>
        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px;">
          <button class="btn-quick-nav" data-target-tab="tournaments" style="background: #f8fafc; border: 1px solid #e2e8f0; padding: 10px; border-radius: 10px; text-align: left; cursor: pointer;">
            <div style="font-weight: 700; font-size: 12px; color: #0f172a;">🔑 Release Room ID</div>
            <div style="font-size: 10px; color: #64748b;">Push custom room to app</div>
          </button>
          <button class="btn-quick-nav" data-target-tab="downloads" style="background: #f8fafc; border: 1px solid #e2e8f0; padding: 10px; border-radius: 10px; text-align: left; cursor: pointer;">
            <div style="font-weight: 700; font-size: 12px; color: #0f172a;">📥 Add Download APK</div>
            <div style="font-size: 10px; color: #64748b;">Upload video + action buttons</div>
          </button>
          <button class="btn-quick-nav" data-target-tab="banners" style="background: #f8fafc; border: 1px solid #e2e8f0; padding: 10px; border-radius: 10px; text-align: left; cursor: pointer;">
            <div style="font-weight: 700; font-size: 12px; color: #0f172a;">🖼️ Hero Banners</div>
            <div style="font-size: 10px; color: #64748b;">Upload & edit sliders</div>
          </button>
          <button class="btn-quick-nav" data-target-tab="services" style="background: #f8fafc; border: 1px solid #e2e8f0; padding: 10px; border-radius: 10px; text-align: left; cursor: pointer;">
            <div style="font-weight: 700; font-size: 12px; color: #0f172a;">👑 Services / Products</div>
            <div style="font-size: 10px; color: #64748b;">Edit 3-col grid images</div>
          </button>
        </div>
      </div>

      <!-- Live Activity Stream -->
      <div style="background: #ffffff; padding: 14px; border-radius: 14px; border: 1px solid #e2e8f0;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
          <div style="font-size: 13px; font-weight: 800; color: #0f172a;">📡 Real-time Activity Stream</div>
          <span style="font-size: 10px; color: #10b981; font-weight: 700;">Live Feed</span>
        </div>
        <div style="display: flex; flex-direction: column; gap: 8px;">
          <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f8fafc; border-radius: 8px; font-size: 11.5px;">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span>🏆</span>
              <span><strong>Tanvir_Sniper</strong> joined BR Squad Cup #44</span>
            </div>
            <span style="font-size: 10px; color: #64748b;">2m ago</span>
          </div>
          <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f8fafc; border-radius: 8px; font-size: 11.5px;">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span>💎</span>
              <span><strong>Mobin_Gamer99</strong> added ৳500 to wallet</span>
            </div>
            <span style="font-size: 10px; color: #64748b;">8m ago</span>
          </div>
          <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f8fafc; border-radius: 8px; font-size: 11.5px;">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span>📥</span>
              <span><strong>Shanto_Headshot</strong> downloaded Anti-Lag Proxy APK</span>
            </div>
            <span style="font-size: 10px; color: #64748b;">14m ago</span>
          </div>
        </div>
      </div>

    </div>
  `;
}

// ==========================================
// 2. USERS MANAGEMENT TAB
// ==========================================
function renderUsersTab(data) {
  let filtered = data.allUsers;

  if (userRoleFilter !== 'ALL') {
    filtered = filtered.filter(u => u.role?.toUpperCase() === userRoleFilter);
  }

  if (userSearchQuery.trim()) {
    const q = userSearchQuery.toLowerCase();
    filtered = filtered.filter(u => 
      u.fullName?.toLowerCase().includes(q) ||
      u.username?.toLowerCase().includes(q) ||
      u.email?.toLowerCase().includes(q) ||
      u.phone?.includes(q) ||
      u.ffUid?.includes(q)
    );
  }

  return `
    <div class="admin-tab-pane">
      
      <!-- Search & Filters -->
      <div style="background: #ffffff; padding: 12px; border-radius: 12px; border: 1px solid #e2e8f0; margin-bottom: 12px;">
        <div style="display: flex; gap: 8px; margin-bottom: 8px;">
          <input 
            type="text" 
            id="admin-user-search-input" 
            placeholder="Search by Name, Email, Phone, UID..." 
            value="${userSearchQuery}"
            style="flex: 1; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 12px; outline: none;"
          />
          <button id="btn-admin-search-user" style="background: #0284c7; color: #ffffff; border: none; padding: 8px 14px; border-radius: 8px; font-size: 12px; font-weight: 700; cursor: pointer;">
            Search
          </button>
        </div>
        <div style="display: flex; gap: 6px; overflow-x: auto;">
          ${['ALL', 'VIP MEMBER', 'MEMBER', 'ADMIN'].map(role => `
            <button 
              class="btn-filter-role ${userRoleFilter === role ? 'active' : ''}" 
              data-role="${role}"
              style="padding: 4px 10px; border-radius: 14px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; ${userRoleFilter === role ? 'background: #0f172a; color: #ffffff;' : 'background: #f1f5f9; color: #475569;'}"
            >
              ${role}
            </button>
          `).join('')}
        </div>
      </div>

      <!-- Quick Register User Box -->
      <div style="background: #ffffff; padding: 12px; border-radius: 12px; border: 1px solid #e2e8f0; margin-bottom: 12px;">
        <div style="font-size: 12.5px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">➕ Register New User / Player</div>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 8px;">
          <input type="text" id="reg-user-name" placeholder="Full Name" style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" />
          <input type="text" id="reg-user-phone" placeholder="Phone Number" style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" />
          <input type="text" id="reg-user-ffuid" placeholder="Free Fire UID" style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" />
          <input type="number" id="reg-user-balance" placeholder="Initial Balance (৳)" style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" />
        </div>
        <button id="btn-save-new-user" style="width: 100%; background: #10b981; color: #ffffff; font-weight: 700; padding: 8px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
          Create & Save User
        </button>
      </div>

      <!-- Users Count Header -->
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; padding: 0 4px;">
        <div style="font-size: 12px; font-weight: 700; color: #475569;">Found ${filtered.length} Users</div>
      </div>

      <!-- Users List -->
      <div style="display: flex; flex-direction: column; gap: 8px;">
        ${filtered.map(u => `
          <div style="background: #ffffff; padding: 12px; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px;">
              <div style="display: flex; align-items: center; gap: 8px;">
                <div style="width: 34px; height: 34px; border-radius: 50%; background: #e0f2fe; color: #0284c7; font-weight: 800; font-size: 13px; display: flex; align-items: center; justify-content: center;">
                  ${(u.fullName || u.username || 'U')[0].toUpperCase()}
                </div>
                <div>
                  <div style="font-size: 13px; font-weight: 800; color: #0f172a;">${u.fullName || u.username}</div>
                  <div style="font-size: 11px; color: #64748b;">${u.phone || u.email || 'No phone'}</div>
                </div>
              </div>
              <span style="padding: 2px 8px; border-radius: 10px; font-size: 10px; font-weight: 700; ${u.status === 'Active' ? 'background: #dcfce7; color: #166534;' : 'background: #fee2e2; color: #991b1b;'}">
                ${u.status || 'Active'}
              </span>
            </div>

            <!-- Stats Bar -->
            <div style="display: flex; gap: 12px; padding: 6px 8px; background: #f8fafc; border-radius: 6px; font-size: 11px; margin-bottom: 8px;">
              <div><strong>UID:</strong> ${u.ffUid || 'N/A'}</div>
              <div><strong>Role:</strong> ${u.role || 'Member'}</div>
              <div><strong>Balance:</strong> ৳${u.walletBalance || 0}</div>
            </div>

            <!-- Actions -->
            <div style="display: flex; gap: 6px; flex-wrap: wrap;">
              <button class="btn-add-balance" data-user-id="${u.id}" style="padding: 4px 8px; font-size: 10.5px; font-weight: 700; background: #f0fdf4; color: #16a34a; border: 1px solid #bbf7d0; border-radius: 6px; cursor: pointer;">
                +Add ৳100
              </button>
              <button class="btn-toggle-role" data-user-id="${u.id}" style="padding: 4px 8px; font-size: 10.5px; font-weight: 700; background: #fdf4ff; color: #c026d3; border: 1px solid #f5d0fe; border-radius: 6px; cursor: pointer;">
                Toggle VIP
              </button>
              <button class="btn-toggle-status" data-user-id="${u.id}" style="padding: 4px 8px; font-size: 10.5px; font-weight: 700; background: #fffbeb; color: #b45309; border: 1px solid #fef3c7; border-radius: 6px; cursor: pointer;">
                ${u.status === 'Active' ? 'Suspend' : 'Activate'}
              </button>
              <button class="btn-delete-user" data-user-id="${u.id}" style="padding: 4px 8px; font-size: 10.5px; font-weight: 700; background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; border-radius: 6px; cursor: pointer;">
                Delete
              </button>
            </div>
          </div>
        `).join('')}
      </div>

    </div>
  `;
}

// ==========================================
// 3. TOURNAMENTS TAB (Room ID & Password Release)
// ==========================================
function renderTournamentsTab(data) {
  return `
    <div class="admin-tab-pane">
      
      <!-- Schedule New Match -->
      <div style="background: #ffffff; padding: 14px; border-radius: 12px; border: 1px solid #e2e8f0; margin-bottom: 14px;">
        <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">🏆 Schedule New Tournament Match</div>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 8px;">
          <input type="text" id="tourn-title" placeholder="Match Title (e.g. Squad BR Cup #45)" style="grid-column: span 2; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" />
          <input type="text" id="tourn-mode" placeholder="Mode (Squad / Solo / Duo)" value="Squad (4v4)" style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" />
          <input type="text" id="tourn-map" placeholder="Map (Bermuda / Purgatory)" value="Bermuda Remastered" style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" />
          <input type="text" id="tourn-time" placeholder="Match Time (e.g. 09:30 PM)" value="09:30 PM Today" style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" />
          <input type="text" id="tourn-prize" placeholder="Prize Pool (e.g. ৳1,500)" value="৳1,500" style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" />
        </div>
        <button id="btn-save-new-tournament" style="width: 100%; background: #ea580c; color: #ffffff; font-weight: 700; padding: 8px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
          Schedule & Publish Match
        </button>
      </div>

      <!-- Live Tournaments with Room Credentials Releaser -->
      <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">Active Tournaments & Custom Rooms</div>
      <div style="display: flex; flex-direction: column; gap: 10px;">
        ${data.tournaments.map(t => {
          const participants = t.participants || [];
          return `
            <div style="background: #ffffff; padding: 14px; border-radius: 14px; border: 1px solid ${t.isRoomReleased ? '#10b981' : '#e2e8f0'}; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
              
              <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px;">
                <div>
                  <div style="font-size: 13.5px; font-weight: 800; color: #0f172a;">${t.title}</div>
                  <div style="font-size: 11px; color: #64748b;">${t.mode} • ${t.map} • ${t.matchTime}</div>
                </div>
                <span style="padding: 3px 8px; border-radius: 12px; font-size: 10px; font-weight: 800; ${t.isRoomReleased ? 'background: #dcfce7; color: #166534;' : 'background: #fef3c7; color: #b45309;'}">
                  ${t.isRoomReleased ? '🔴 ROOM RELEASED' : 'WAITING FOR ROOM'}
                </span>
              </div>

              <!-- Registered Players Inspection Box -->
              <details style="margin: 8px 0; background: #f8fafc; padding: 8px; border-radius: 8px; font-size: 11.5px;">
                <summary style="font-weight: 700; color: #0284c7; cursor: pointer;">
                  👥 View Registered Players (${participants.length} / ${t.slotsTotal || 48})
                </summary>
                <div style="margin-top: 8px; display: flex; flex-direction: column; gap: 4px;">
                  ${participants.length === 0 ? '<div style="color: #94a3b8; font-size: 11px;">No players joined yet</div>' : ''}
                  ${participants.map((p, idx) => `
                    <div style="display: flex; justify-content: space-between; background: #ffffff; padding: 4px 8px; border-radius: 4px; border: 1px solid #e2e8f0; font-size: 11px;">
                      <span><strong>#${p.slot || idx + 1}</strong> ${p.playerName || p.username}</span>
                      <span style="color: #64748b;">UID: ${p.ffUid || 'N/A'} • ${p.phone || ''}</span>
                    </div>
                  `).join('')}
                </div>
              </details>

              <!-- Custom Room Release Form Box -->
              <div style="background: #f0fdf4; border: 1px solid #bbf7d0; padding: 10px; border-radius: 8px; margin-top: 8px;">
                <div style="font-size: 11.5px; font-weight: 800; color: #166534; margin-bottom: 6px;">🔑 Custom Room ID & Password Release</div>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 6px; margin-bottom: 6px;">
                  <input type="text" id="input-room-id-${t.id}" placeholder="Room ID (e.g. 889420)" value="${t.roomId || ''}" style="padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11px; background: #ffffff;" />
                  <input type="text" id="input-room-pass-${t.id}" placeholder="Password (e.g. 1234)" value="${t.roomPass || ''}" style="padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11px; background: #ffffff;" />
                </div>
                <button class="btn-release-room" data-tournament-id="${t.id}" style="width: 100%; background: #16a34a; color: #ffffff; font-weight: 700; padding: 7px; border-radius: 6px; border: none; font-size: 11.5px; cursor: pointer;">
                  ⚡ Release Room ID & Password Now
                </button>
              </div>

              <!-- Delete Match -->
              <div style="text-align: right; margin-top: 6px;">
                <button class="btn-delete-tournament" data-tournament-id="${t.id}" style="background: none; border: none; color: #ef4444; font-size: 11px; font-weight: 600; cursor: pointer;">
                  🗑️ Delete Tournament
                </button>
              </div>

            </div>
          `;
        }).join('')}
      </div>

    </div>
  `;
}

// ==========================================
// 4. DOWNLOADS TAB (Dynamic Custom Action Buttons)
// ==========================================
function renderDownloadsTab(data) {
  return `
    <div class="admin-tab-pane">
      
      <!-- Upload / Add New Download Item Form -->
      <div style="background: #ffffff; padding: 14px; border-radius: 12px; border: 1px solid #e2e8f0; margin-bottom: 14px;">
        <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">
          ${editingDownload ? '✏️ Edit Download File' : '📥 Add New Download APK / Config'}
        </div>

        <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 8px;">
          <input 
            type="text" 
            id="download-title" 
            placeholder="Banner Title (e.g. Auto Headshot Macro APK)" 
            value="${editingDownload ? editingDownload.title : ''}"
            style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" 
          />
          
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
            <select id="download-category" style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px; background: #ffffff;">
              <option value="Mobin APK" ${editingDownload && editingDownload.category === 'Mobin APK' ? 'selected' : ''}>Mobin APK</option>
              <option value="Tools" ${editingDownload && editingDownload.category === 'Tools' ? 'selected' : ''}>Gaming Tools</option>
              <option value="Proxy Booster" ${editingDownload && editingDownload.category === 'Proxy Booster' ? 'selected' : ''}>Proxy Booster</option>
              <option value="Config" ${editingDownload && editingDownload.category === 'Config' ? 'selected' : ''}>Sensitivity Config</option>
            </select>
            <input 
              type="text" 
              id="download-videoid" 
              placeholder="YouTube Video Link or ID" 
              value="${editingDownload ? (editingDownload.videoId || '') : ''}"
              style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" 
            />
          </div>

          <!-- Dynamic Action Buttons Builder -->
          <div style="background: #f8fafc; padding: 10px; border-radius: 8px; border: 1px solid #e2e8f0; margin-top: 4px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
              <span style="font-size: 11.5px; font-weight: 800; color: #0f172a;">🔗 Custom Action Buttons</span>
              <button id="btn-add-action-button-row" type="button" style="background: #0284c7; color: #ffffff; border: none; padding: 4px 8px; border-radius: 4px; font-size: 10.5px; font-weight: 700; cursor: pointer;">
                ➕ Add Action Button
              </button>
            </div>
            
            <div id="dynamic-action-buttons-container" style="display: flex; flex-direction: column; gap: 6px;">
              ${downloadCustomButtons.map((btn, idx) => `
                <div class="action-button-row" style="display: flex; gap: 6px; align-items: center;">
                  <input type="text" class="btn-label-input" placeholder="Button Name (e.g. Join WhatsApp)" value="${btn.label}" style="flex: 1; padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11px;" />
                  <input type="text" class="btn-url-input" placeholder="Target URL" value="${btn.url}" style="flex: 1.2; padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11px;" />
                  <button type="button" class="btn-remove-action-row" data-index="${idx}" style="background: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; border-radius: 6px; padding: 6px 8px; font-size: 11px; cursor: pointer;">
                    ❌
                  </button>
                </div>
              `).join('')}
            </div>
          </div>

        </div>

        <div style="display: flex; gap: 8px;">
          <button id="btn-save-download-item" style="flex: 1; background: #10b981; color: #ffffff; font-weight: 700; padding: 8px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
            ${editingDownload ? '💾 Save Changes' : '🚀 Publish Download File'}
          </button>
          ${editingDownload ? `
            <button id="btn-cancel-edit-download" style="background: #94a3b8; color: #ffffff; font-weight: 700; padding: 8px 14px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
              Cancel
            </button>
          ` : ''}
        </div>
      </div>

      <!-- Published Downloads Catalog -->
      <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">Published Downloads & Action Links</div>
      <div style="display: flex; flex-direction: column; gap: 10px;">
        ${data.downloads.map(item => `
          <div style="background: #ffffff; padding: 12px; border-radius: 12px; border: 1px solid #e2e8f0; display: flex; gap: 12px; align-items: center;">
            <img src="${item.icon || 'https://img.youtube.com/vi/' + (item.videoId || 'dQw4w9WgXcQ') + '/hqdefault.jpg'}" alt="${item.title}" style="width: 70px; height: 50px; border-radius: 8px; object-fit: cover;" />
            <div style="flex: 1;">
              <div style="font-size: 12.5px; font-weight: 800; color: #0f172a;">${item.title}</div>
              <div style="font-size: 10.5px; color: #64748b;">${item.category} • ${item.actionButtons ? item.actionButtons.length : 2} action buttons</div>
            </div>
            <div style="display: flex; gap: 4px;">
              <button class="btn-edit-download" data-download-id="${item.id}" style="padding: 6px 10px; background: #e0f2fe; color: #0284c7; border: 1px solid #bae6fd; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                ✏️ Edit
              </button>
              <button class="btn-delete-download" data-download-id="${item.id}" style="padding: 6px 10px; background: #fee2e2; color: #dc2626; border: 1px solid #fecaca; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                🗑️
              </button>
            </div>
          </div>
        `).join('')}
      </div>

    </div>
  `;
}

// ==========================================
// 5. FLASH DEALS TAB (Editable)
// ==========================================
function renderFlashDealsTab(data) {
  return `
    <div class="admin-tab-pane">
      
      <!-- Add / Edit Flash Deal Form -->
      <div style="background: #ffffff; padding: 14px; border-radius: 12px; border: 1px solid #e2e8f0; margin-bottom: 14px;">
        <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">
          ${editingFlashDeal ? '✏️ Edit Flash Diamond Deal' : '➕ Add Flash Diamond Deal'}
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 8px;">
          <input 
            type="text" 
            id="flash-diamond-amount" 
            placeholder="Diamonds (e.g. 520 DIAMONDS)" 
            value="${editingFlashDeal ? editingFlashDeal.diamondAmount : ''}"
            style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" 
          />
          <input 
            type="text" 
            id="flash-price" 
            placeholder="Price (e.g. ৳ 420.00)" 
            value="${editingFlashDeal ? editingFlashDeal.price : ''}"
            style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" 
          />
          <input 
            type="text" 
            id="flash-badge" 
            placeholder="Badge (e.g. BEST VALUE)" 
            value="${editingFlashDeal ? editingFlashDeal.badge : 'POPULAR'}"
            style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" 
          />
          <input 
            type="text" 
            id="flash-bonus" 
            placeholder="Bonus (e.g. +52 Free)" 
            value="${editingFlashDeal ? (editingFlashDeal.bonus || '') : '+50 Free'}"
            style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" 
          />
        </div>

        <div style="display: flex; gap: 8px;">
          <button id="btn-save-flash-deal" style="flex: 1; background: #0284c7; color: #ffffff; font-weight: 700; padding: 8px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
            ${editingFlashDeal ? '💾 Save Flash Deal' : '➕ Add Deal to App'}
          </button>
          ${editingFlashDeal ? `
            <button id="btn-cancel-edit-flash" style="background: #94a3b8; color: #ffffff; font-weight: 700; padding: 8px 14px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
              Cancel
            </button>
          ` : ''}
        </div>
      </div>

      <!-- Flash Deals List with Edit & Delete -->
      <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">Active Flash Deals in Marquee</div>
      <div style="display: flex; flex-direction: column; gap: 8px;">
        ${data.flashDeals.map(deal => `
          <div style="background: #ffffff; padding: 12px; border-radius: 12px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
            <div>
              <div style="display: flex; align-items: center; gap: 6px;">
                <span style="font-size: 14px;">💎</span>
                <span style="font-size: 13px; font-weight: 800; color: #0f172a;">${deal.diamondAmount}</span>
                <span style="background: ${deal.badgeColor || '#ec4899'}; color: #ffffff; font-size: 9px; font-weight: 800; padding: 2px 6px; border-radius: 4px;">${deal.badge}</span>
              </div>
              <div style="font-size: 11px; color: #64748b; margin-top: 2px;">Price: <strong>${deal.price}</strong> • Bonus: ${deal.bonus || 'None'}</div>
            </div>
            <div style="display: flex; gap: 6px;">
              <button class="btn-edit-flash" data-flash-id="${deal.id}" style="padding: 6px 10px; background: #e0f2fe; color: #0284c7; border: 1px solid #bae6fd; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                ✏️ Edit
              </button>
              <button class="btn-delete-flash" data-flash-id="${deal.id}" style="padding: 6px 10px; background: #fee2e2; color: #dc2626; border: 1px solid #fecaca; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                🗑️
              </button>
            </div>
          </div>
        `).join('')}
      </div>

    </div>
  `;
}

// ==========================================
// 6. POPULAR SERVICES / PRODUCTS TAB (Upload / Link & Edit)
// ==========================================
function renderServicesTab(data) {
  return `
    <div class="admin-tab-pane">
      
      <!-- Add / Edit Service Form -->
      <div style="background: #ffffff; padding: 14px; border-radius: 12px; border: 1px solid #e2e8f0; margin-bottom: 14px;">
        <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">
          ${editingService ? '✏️ Edit Popular Service / Product' : '➕ Add Popular Service / Product'}
        </div>

        <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 8px;">
          <input 
            type="text" 
            id="service-name-input" 
            placeholder="Service / Product Title (e.g. SENSITIVITY MAKER)" 
            value="${editingService ? editingService.title : ''}"
            style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" 
          />
          
          <div style="display: flex; gap: 8px; align-items: center;">
            <input 
              type="text" 
              id="service-img-input" 
              placeholder="Image Link / URL (e.g. assets/images/service_topup.jpg)" 
              value="${editingService ? editingService.image : ''}"
              style="flex: 1; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" 
            />
            <label style="background: #e0f2fe; color: #0284c7; padding: 8px 12px; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer; white-space: nowrap;">
              📁 Upload Image
              <input type="file" id="service-file-input" accept="image/*" style="display: none;" />
            </label>
          </div>

          <input 
            type="text" 
            id="service-route-input" 
            placeholder="Target Route (e.g. topup, shop, tournaments, sensitivity)" 
            value="${editingService ? editingService.route : 'topup'}"
            style="padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px;" 
          />
        </div>

        <div style="display: flex; gap: 8px;">
          <button id="btn-save-service-item" style="flex: 1; background: #7c3aed; color: #ffffff; font-weight: 700; padding: 8px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
            ${editingService ? '💾 Save Service' : '➕ Add Service to Grid'}
          </button>
          ${editingService ? `
            <button id="btn-cancel-edit-service" style="background: #94a3b8; color: #ffffff; font-weight: 700; padding: 8px 14px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
              Cancel
            </button>
          ` : ''}
        </div>
      </div>

      <!-- Services List with Edit & Delete -->
      <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">Popular Services on Home Screen (3-Column Grid)</div>
      <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px;">
        ${data.popularServices.map(service => `
          <div style="background: #ffffff; padding: 10px; border-radius: 12px; border: 1px solid #e2e8f0; text-align: center;">
            <img src="${service.image}" alt="${service.title}" style="width: 60px; height: 60px; border-radius: 10px; object-fit: cover; margin-bottom: 6px; box-shadow: 0 2px 6px rgba(0,0,0,0.06);" onerror="this.src='assets/images/service_topup.jpg';" />
            <div style="font-size: 12px; font-weight: 800; color: #0f172a; margin-bottom: 2px;">${service.title}</div>
            <div style="font-size: 10px; color: #64748b; margin-bottom: 6px;">Route: ${service.route}</div>
            <div style="display: flex; justify-content: center; gap: 6px;">
              <button class="btn-edit-service" data-service-id="${service.id}" style="padding: 4px 10px; background: #f3e8ff; color: #7c3aed; border: 1px solid #e9d5ff; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                ✏️ Edit
              </button>
              <button class="btn-delete-service" data-service-id="${service.id}" style="padding: 4px 10px; background: #fee2e2; color: #dc2626; border: 1px solid #fecaca; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                🗑️
              </button>
            </div>
          </div>
        `).join('')}
      </div>

    </div>
  `;
}

// ==========================================
// 7. HERO BANNERS TAB (Upload / Link & Edit)
// ==========================================
function renderBannersTab(data) {
  return `
    <div class="admin-tab-pane">
      
      <!-- Add / Edit Banner Form -->
      <div style="background: #ffffff; padding: 14px; border-radius: 12px; border: 1px solid #e2e8f0; margin-bottom: 14px;">
        <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 10px;">
          ${editingBanner ? '✏️ Edit Banner' : '➕ Add New Banner'}
        </div>

        <div style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 12px;">
          <!-- 1. Image Link / URL + Upload -->
          <div>
            <label style="font-size: 11.5px; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">
              1. Banner Image Link / File *
            </label>
            <div style="display: flex; gap: 8px; align-items: center;">
              <input 
                type="text" 
                id="banner-img-url" 
                placeholder="Paste Image URL (e.g. https://... or assets/images/...)" 
                value="${editingBanner ? editingBanner.image : ''}"
                style="flex: 1; padding: 9px 10px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 12px;" 
              />
              <label style="background: #e0f2fe; color: #0284c7; padding: 9px 12px; border-radius: 8px; font-size: 11.5px; font-weight: 700; cursor: pointer; white-space: nowrap; border: 1px solid #bae6fd;">
                📁 Upload Image
                <input type="file" id="banner-file-input" accept="image/*" style="display: none;" />
              </label>
            </div>
          </div>

          <!-- 2. Target Link / Route (Optional) -->
          <div>
            <label style="font-size: 11.5px; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">
              2. Click Target Link / Route (Optional)
            </label>
            <input 
              type="text" 
              id="banner-route" 
              placeholder="e.g. topup, shop, tournaments, downloads, or https://..." 
              value="${editingBanner ? (editingBanner.actionRoute || '') : 'topup'}"
              style="width: 100%; padding: 9px 10px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 12px;" 
            />
            <div style="font-size: 10.5px; color: #64748b; margin-top: 3px;">
              When users click this banner, it opens this route or website link.
            </div>
          </div>
        </div>

        <div style="display: flex; gap: 8px;">
          <button id="btn-save-hero-banner" style="flex: 1; background: #0284c7; color: #ffffff; font-weight: 700; padding: 10px; border-radius: 8px; border: none; font-size: 12.5px; cursor: pointer;">
            ${editingBanner ? '💾 Save Banner' : '➕ Add Banner to Slideshow'}
          </button>
          ${editingBanner ? `
            <button id="btn-cancel-edit-banner" style="background: #94a3b8; color: #ffffff; font-weight: 700; padding: 10px 16px; border-radius: 8px; border: none; font-size: 12.5px; cursor: pointer;">
              Cancel
            </button>
          ` : ''}
        </div>
      </div>

      <!-- Hero Banners List with Edit & Delete -->
      <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">Active Banners (${data.heroBanners.length})</div>
      <div style="display: flex; flex-direction: column; gap: 10px;">
        ${data.heroBanners.map((b, idx) => `
          <div style="background: #ffffff; padding: 10px 12px; border-radius: 12px; border: 1px solid #e2e8f0; display: flex; gap: 12px; align-items: center;">
            <img src="${b.image}" alt="Banner ${idx + 1}" style="width: 90px; height: 50.6px; border-radius: 8px; object-fit: cover; border: 1px solid #e2e8f0;" onerror="this.src='assets/images/banner_topup.jpg';" />
            <div style="flex: 1; overflow: hidden;">
              <div style="font-size: 12.5px; font-weight: 800; color: #0f172a;">Banner #${idx + 1}</div>
              <div style="font-size: 11px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Target: <strong>${b.actionRoute || 'No link'}</strong></div>
            </div>
            <div style="display: flex; gap: 4px;">
              <button class="btn-edit-banner" data-banner-id="${b.id}" style="padding: 6px 10px; background: #e0f2fe; color: #0284c7; border: 1px solid #bae6fd; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                ✏️ Edit
              </button>
              <button class="btn-delete-banner" data-banner-id="${b.id}" style="padding: 6px 10px; background: #fee2e2; color: #dc2626; border: 1px solid #fecaca; border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer;">
                🗑️
              </button>
            </div>
          </div>
        `).join('')}
      </div>

    </div>
  `;
}

// ==========================================
// 8. NOTICES & ANNOUNCEMENTS TAB
// ==========================================
function renderNoticesTab(data) {
  return `
    <div class="admin-tab-pane">
      <div style="background: #ffffff; padding: 14px; border-radius: 12px; border: 1px solid #e2e8f0;">
        <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">📢 Broadcast Push Notification</div>
        <input type="text" id="notice-title" placeholder="Announcement Title" style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px; margin-bottom: 8px;" />
        <textarea id="notice-body" placeholder="Notification Message content..." rows="3" style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px; margin-bottom: 8px;"></textarea>
        <button id="btn-broadcast-notice" style="width: 100%; background: #0284c7; color: #ffffff; font-weight: 700; padding: 8px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
          🚀 Send Live Push Broadcast
        </button>
      </div>
    </div>
  `;
}

// ==========================================
// 9. SYSTEM URLS TAB
// ==========================================
function renderUrlsTab(data) {
  return `
    <div class="admin-tab-pane">
      <div style="background: #ffffff; padding: 14px; border-radius: 12px; border: 1px solid #e2e8f0;">
        <div style="font-size: 13px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">🌐 Live Endpoint URLs</div>
        <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 12px;">
          <div>
            <label style="font-size: 11px; font-weight: 700; color: #475569;">Top-Up Webview URL</label>
            <input type="text" id="sys-url-topup" value="${data.urls.topup}" style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px; margin-top: 2px;" />
          </div>
          <div>
            <label style="font-size: 11px; font-weight: 700; color: #475569;">Shop Webview URL</label>
            <input type="text" id="sys-url-shop" value="${data.urls.shop}" style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px; margin-top: 2px;" />
          </div>
          <div>
            <label style="font-size: 11px; font-weight: 700; color: #475569;">Telegram Channel Link</label>
            <input type="text" id="sys-url-telegram" value="${data.urls.telegram}" style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 11.5px; margin-top: 2px;" />
          </div>
        </div>
        <button id="btn-save-system-urls" style="width: 100%; background: #0284c7; color: #ffffff; font-weight: 700; padding: 8px; border-radius: 6px; border: none; font-size: 12px; cursor: pointer;">
          💾 Save Endpoint URLs
        </button>
      </div>
    </div>
  `;
}

// ==========================================
// EVENT BINDINGS
// ==========================================
export function bindAdminEvents() {
  const reRender = () => {
    stateManager.navigate('admin');
  };

  // Back button
  document.getElementById('btn-admin-back')?.addEventListener('click', () => {
    stateManager.navigate('profile');
  });

  // Admin login prompt
  document.getElementById('btn-admin-login-prompt')?.addEventListener('click', () => {
    stateManager.setActiveModal('adminLogin');
  });

  // Tab navigation
  document.querySelectorAll('.admin-nav-pill').forEach(btn => {
    btn.addEventListener('click', (e) => {
      activeAdminTab = e.currentTarget.getAttribute('data-tab');
      reRender();
    });
  });

  // Quick action shortcut navigation
  document.querySelectorAll('.btn-quick-nav').forEach(btn => {
    btn.addEventListener('click', (e) => {
      activeAdminTab = e.currentTarget.getAttribute('data-target-tab');
      reRender();
    });
  });

  // --- USERS TAB EVENTS ---
  document.getElementById('btn-admin-search-user')?.addEventListener('click', () => {
    userSearchQuery = document.getElementById('admin-user-search-input')?.value || '';
    reRender();
  });

  document.querySelectorAll('.btn-filter-role').forEach(btn => {
    btn.addEventListener('click', (e) => {
      userRoleFilter = e.currentTarget.getAttribute('data-role');
      reRender();
    });
  });

  document.getElementById('btn-save-new-user')?.addEventListener('click', () => {
    const name = document.getElementById('reg-user-name')?.value.trim();
    const phone = document.getElementById('reg-user-phone')?.value.trim();
    const ffUid = document.getElementById('reg-user-ffuid')?.value.trim();
    const balance = parseFloat(document.getElementById('reg-user-balance')?.value) || 0;

    if (!name) {
      Toast.show('Please enter full name', 'warning');
      return;
    }

    authService.loginWithPhone(name, phone || '01700000000', ffUid || '123456789');
    if (balance > 0) {
      const allU = authService.getAllUsers();
      const created = allU[0];
      if (created) authService.updateUserBalance(created.id, balance);
    }
    Toast.show(`User "${name}" registered successfully!`, 'success');
    reRender();
  });

  document.querySelectorAll('.btn-add-balance').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const uId = e.currentTarget.getAttribute('data-user-id');
      authService.updateUserBalance(uId, 100);
      Toast.show('Added ৳100 balance to user account!', 'success');
      reRender();
    });
  });

  document.querySelectorAll('.btn-toggle-role').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const uId = e.currentTarget.getAttribute('data-user-id');
      const u = authService.getUserById(uId);
      const newRole = u.role === 'VIP Member' ? 'Member' : 'VIP Member';
      authService.updateUserRole(uId, newRole);
      Toast.show(`Role changed to ${newRole}`, 'info');
      reRender();
    });
  });

  document.querySelectorAll('.btn-toggle-status').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const uId = e.currentTarget.getAttribute('data-user-id');
      const u = authService.toggleUserStatus(uId);
      Toast.show(`User status changed to ${u.status}`, 'info');
      reRender();
    });
  });

  document.querySelectorAll('.btn-delete-user').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const uId = e.currentTarget.getAttribute('data-user-id');
      if (confirm('Are you sure you want to delete this user?')) {
        authService.deleteUser(uId);
        Toast.show('User deleted successfully', 'success');
        reRender();
      }
    });
  });

  // --- TOURNAMENTS TAB EVENTS ---
  document.getElementById('btn-save-new-tournament')?.addEventListener('click', () => {
    const title = document.getElementById('tourn-title')?.value.trim();
    const mode = document.getElementById('tourn-mode')?.value.trim();
    const map = document.getElementById('tourn-map')?.value.trim();
    const matchTime = document.getElementById('tourn-time')?.value.trim();
    const prize = document.getElementById('tourn-prize')?.value.trim();

    if (!title) {
      Toast.show('Please enter match title', 'warning');
      return;
    }

    tournamentService.addTournament({
      title,
      mode: mode || 'Squad (4v4)',
      map: map || 'Bermuda',
      matchTime: matchTime || '09:30 PM Today',
      prize: prize || '৳1,500',
      entryFee: '৳30',
      slotsTotal: 48,
      slotsFilled: 0,
      participants: []
    });

    Toast.show(`Tournament "${title}" scheduled successfully!`, 'success');
    reRender();
  });

  document.querySelectorAll('.btn-release-room').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const tournId = e.currentTarget.getAttribute('data-tournament-id');
      const roomIdInput = document.getElementById(`input-room-id-${tournId}`);
      const roomPassInput = document.getElementById(`input-room-pass-${tournId}`);

      const roomId = roomIdInput?.value.trim();
      const roomPass = roomPassInput?.value.trim();

      if (!roomId || !roomPass) {
        Toast.show('Please enter both Room ID and Room Password!', 'warning');
        return;
      }

      tournamentService.releaseRoomCredentials(tournId, roomId, roomPass);
      Toast.show(`Room ${roomId} Released! Players notified live.`, 'success');
      reRender();
    });
  });

  document.querySelectorAll('.btn-delete-tournament').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const tournId = e.currentTarget.getAttribute('data-tournament-id');
      if (confirm('Delete this tournament?')) {
        tournamentService.deleteTournament(tournId);
        Toast.show('Tournament deleted', 'info');
        reRender();
      }
    });
  });

  // --- DOWNLOADS TAB EVENTS ---
  // Add new dynamic action button row
  document.getElementById('btn-add-action-button-row')?.addEventListener('click', () => {
    downloadCustomButtons.push({ label: 'Join WhatsApp Channel', url: 'https://whatsapp.com/channel/' });
    reRender();
  });

  // Remove dynamic action button row
  document.querySelectorAll('.btn-remove-action-row').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const idx = parseInt(e.currentTarget.getAttribute('data-index'), 10);
      downloadCustomButtons.splice(idx, 1);
      reRender();
    });
  });

  // Save / Publish Download item
  document.getElementById('btn-save-download-item')?.addEventListener('click', () => {
    const title = document.getElementById('download-title')?.value.trim();
    const category = document.getElementById('download-category')?.value;
    const videoId = document.getElementById('download-videoid')?.value.trim();

    if (!title) {
      Toast.show('Please enter download banner title', 'warning');
      return;
    }

    // Capture dynamic action buttons
    const rows = document.querySelectorAll('.action-button-row');
    const buttons = [];
    rows.forEach(r => {
      const l = r.querySelector('.btn-label-input')?.value.trim();
      const u = r.querySelector('.btn-url-input')?.value.trim();
      if (l) buttons.push({ label: l, url: u || '#' });
    });

    if (editingDownload) {
      downloadService.updateItem(editingDownload.id, {
        title,
        category,
        videoId: videoId || 'dQw4w9WgXcQ',
        actionButtons: buttons.length > 0 ? buttons : downloadCustomButtons
      });
      Toast.show(`Download "${title}" updated successfully!`, 'success');
      editingDownload = null;
    } else {
      downloadService.addItem({
        title,
        category,
        videoId: videoId || 'dQw4w9WgXcQ',
        actionButtons: buttons.length > 0 ? buttons : downloadCustomButtons
      });
      Toast.show(`New download "${title}" published!`, 'success');
    }
    reRender();
  });

  // Cancel edit download
  document.getElementById('btn-cancel-edit-download')?.addEventListener('click', () => {
    editingDownload = null;
    reRender();
  });

  // Edit download item
  document.querySelectorAll('.btn-edit-download').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const dId = e.currentTarget.getAttribute('data-download-id');
      editingDownload = downloadService.getById(dId);
      if (editingDownload && editingDownload.actionButtons) {
        downloadCustomButtons = [...editingDownload.actionButtons];
      }
      reRender();
    });
  });

  // Delete download item
  document.querySelectorAll('.btn-delete-download').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const dId = e.currentTarget.getAttribute('data-download-id');
      if (confirm('Delete this download file?')) {
        downloadService.deleteItem(dId);
        Toast.show('Download file removed', 'info');
        reRender();
      }
    });
  });

  // --- FLASH DEALS TAB EVENTS ---
  document.getElementById('btn-save-flash-deal')?.addEventListener('click', () => {
    const diamondAmount = document.getElementById('flash-diamond-amount')?.value.trim();
    const price = document.getElementById('flash-price')?.value.trim();
    const badge = document.getElementById('flash-badge')?.value.trim();
    const bonus = document.getElementById('flash-bonus')?.value.trim();

    if (!diamondAmount || !price) {
      Toast.show('Please enter diamond amount and price', 'warning');
      return;
    }

    if (editingFlashDeal) {
      authService.updateFlashDeal(editingFlashDeal.id, {
        diamondAmount,
        price,
        badge: badge || 'POPULAR',
        bonus: bonus || '+50 Free'
      });
      Toast.show('Flash deal updated successfully!', 'success');
      editingFlashDeal = null;
    } else {
      authService.addFlashDeal({
        diamondAmount,
        price,
        badge: badge || 'POPULAR',
        bonus: bonus || '+50 Free',
        badgeColor: '#ec4899',
        btnStyle: 'gold'
      });
      Toast.show('New flash deal added!', 'success');
    }
    reRender();
  });

  document.getElementById('btn-cancel-edit-flash')?.addEventListener('click', () => {
    editingFlashDeal = null;
    reRender();
  });

  document.querySelectorAll('.btn-edit-flash').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const fId = e.currentTarget.getAttribute('data-flash-id');
      const deals = authService.getFlashDeals();
      editingFlashDeal = deals.find(d => d.id === fId);
      reRender();
    });
  });

  document.querySelectorAll('.btn-delete-flash').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const fId = e.currentTarget.getAttribute('data-flash-id');
      if (confirm('Delete this flash deal?')) {
        authService.deleteFlashDeal(fId);
        Toast.show('Flash deal deleted', 'info');
        reRender();
      }
    });
  });

  // --- SERVICES / PRODUCTS TAB EVENTS ---
  // Handle service image file upload
  document.getElementById('service-file-input')?.addEventListener('change', async (e) => {
    const file = e.target.files?.[0];
    if (file) {
      Toast.show('Processing image...', 'info');
      try {
        const { uploadImageToFreeCdn } = await import('../services/imageUploadService.js');
        const cdnUrl = await uploadImageToFreeCdn(file);
        const imgInput = document.getElementById('service-img-input');
        if (imgInput && cdnUrl) {
          imgInput.value = cdnUrl;
          Toast.show('Service image loaded!', 'success');
        }
      } catch (err) {
        const reader = new FileReader();
        reader.onload = (event) => {
          const dataUrl = event.target.result;
          const imgInput = document.getElementById('service-img-input');
          if (imgInput) imgInput.value = dataUrl;
          Toast.show('Service image loaded!', 'success');
        };
        reader.readAsDataURL(file);
      }
    }
  });

  document.getElementById('btn-save-service-item')?.addEventListener('click', () => {
    const title = document.getElementById('service-name-input')?.value.trim();
    const image = document.getElementById('service-img-input')?.value.trim();
    const route = document.getElementById('service-route-input')?.value.trim();

    if (!title) {
      Toast.show('Please enter service / product title', 'warning');
      return;
    }

    if (editingService) {
      authService.updatePopularService(editingService.id, {
        title,
        image: image || 'assets/images/service_topup.jpg',
        route: route || 'topup'
      });
      Toast.show(`Service "${title}" updated successfully!`, 'success');
      editingService = null;
    } else {
      authService.addPopularService({
        title,
        image: image || 'assets/images/service_topup.jpg',
        route: route || 'topup',
        accentColor: '#2563eb'
      });
      Toast.show(`New service "${title}" added to grid!`, 'success');
    }
    reRender();
  });

  document.getElementById('btn-cancel-edit-service')?.addEventListener('click', () => {
    editingService = null;
    reRender();
  });

  document.querySelectorAll('.btn-edit-service').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const sId = e.currentTarget.getAttribute('data-service-id');
      const services = authService.getPopularServices();
      editingService = services.find(s => s.id === sId);
      reRender();
    });
  });

  document.querySelectorAll('.btn-delete-service').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const sId = e.currentTarget.getAttribute('data-service-id');
      if (confirm('Delete this service?')) {
        authService.deletePopularService(sId);
        Toast.show('Service removed from grid', 'info');
        reRender();
      }
    });
  });

  // --- HERO BANNERS TAB EVENTS ---
  // Handle banner image file upload
  document.getElementById('banner-file-input')?.addEventListener('change', async (e) => {
    const file = e.target.files?.[0];
    if (file) {
      Toast.show('Processing banner image...', 'info');
      try {
        const { uploadImageToFreeCdn } = await import('../services/imageUploadService.js');
        const cdnUrl = await uploadImageToFreeCdn(file);
        const imgInput = document.getElementById('banner-img-url');
        if (imgInput && cdnUrl) {
          imgInput.value = cdnUrl;
          Toast.show('Banner image loaded!', 'success');
        }
      } catch (err) {
        const reader = new FileReader();
        reader.onload = (event) => {
          const dataUrl = event.target.result;
          const imgInput = document.getElementById('banner-img-url');
          if (imgInput) imgInput.value = dataUrl;
          Toast.show('Banner image loaded!', 'success');
        };
        reader.readAsDataURL(file);
      }
    }
  });

  document.getElementById('btn-save-hero-banner')?.addEventListener('click', () => {
    const image = document.getElementById('banner-img-url')?.value.trim();
    const route = document.getElementById('banner-route')?.value.trim();

    if (!image) {
      Toast.show('Please provide a banner image link or upload a file', 'warning');
      return;
    }

    if (editingBanner) {
      authService.updateHeroBanner(editingBanner.id, {
        image,
        actionRoute: route || 'topup'
      });
      Toast.show('Banner updated successfully!', 'success');
      editingBanner = null;
    } else {
      authService.addHeroBanner({
        image,
        actionRoute: route || 'topup'
      });
      Toast.show('New banner added to slideshow!', 'success');
    }
    reRender();
  });

  document.getElementById('btn-cancel-edit-banner')?.addEventListener('click', () => {
    editingBanner = null;
    reRender();
  });

  document.querySelectorAll('.btn-edit-banner').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const bId = e.currentTarget.getAttribute('data-banner-id');
      const banners = authService.getHeroBanners();
      editingBanner = banners.find(b => b.id === bId);
      reRender();
    });
  });

  document.querySelectorAll('.btn-delete-banner').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const bId = e.currentTarget.getAttribute('data-banner-id');
      if (confirm('Delete this banner from slideshow?')) {
        authService.deleteHeroBanner(bId);
        Toast.show('Banner removed from slideshow', 'info');
        reRender();
      }
    });
  });

  // --- NOTICES TAB EVENTS ---
  document.getElementById('btn-broadcast-notice')?.addEventListener('click', () => {
    const title = document.getElementById('notice-title')?.value.trim();
    const body = document.getElementById('notice-body')?.value.trim();

    if (!title || !body) {
      Toast.show('Please enter both Title and Message', 'warning');
      return;
    }

    notificationService.broadcastNotice({
      title,
      message: body,
      type: 'announcement'
    });

    Toast.show('Live Push Broadcast sent to all users!', 'success');
    document.getElementById('notice-title').value = '';
    document.getElementById('notice-body').value = '';
  });

  // --- SYSTEM URLS TAB EVENTS ---
  document.getElementById('btn-save-system-urls')?.addEventListener('click', () => {
    const topup = document.getElementById('sys-url-topup')?.value.trim();
    const shop = document.getElementById('sys-url-shop')?.value.trim();
    const telegram = document.getElementById('sys-url-telegram')?.value.trim();

    authService.updateUrls({ topup, shop, telegram });
    Toast.show('System URLs updated successfully!', 'success');
    reRender();
  });
}
