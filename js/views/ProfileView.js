import { authService } from '../services/authService.js';
import { firebaseService } from '../services/firebaseService.js';
import { stateManager } from '../services/stateManager.js';
import { Toast } from '../components/Toast.js';
import { resetOnboardingStep } from './OnboardingView.js';
import { openExternalStore } from '../services/browserService.js';

export function renderProfileView() {
  const user = authService.getCurrentUser() || {};
  const isAdmin = authService.isAdmin();
  const savedSens = authService.getSavedSensitivities() || [];
  const stats = user.stats || {};
  const tournamentsJoined = stats.tournamentsJoined ?? 0;
  const totalDownloads = stats.totalDownloads ?? 0;
  const playerNumber = user.playerNumber ? `#${String(user.playerNumber).padStart(4, '0')}` : '#0001';
  const referralCode = user.referralCode || 'MOBINXVIP';
  const ffUid = user.ffUid || user.freeFireUid || '';

  return `
    <div class="view-container profile-view" style="background: #f8fafc; min-height: 100%; padding: 14px 14px 30px 14px; display: flex; flex-direction: column; gap: 16px;">
      
      <!-- 1. Top User Profile Card -->
      <div class="profile-card-top" style="background: #ffffff; border-radius: 20px; border: 1px solid #e2e8f0; padding: 16px; box-shadow: 0 4px 16px rgba(0, 0, 0, 0.03); position: relative;">
        <div style="display: flex; align-items: center; justify-content: space-between; gap: 12px;">
          
          <div style="display: flex; align-items: center; gap: 12px;">
            <!-- Avatar with glow and badge -->
            <div class="profile-avatar-circle" style="width: 58px; height: 58px; border-radius: 50%; overflow: hidden; border: 2.5px solid #38bdf8; box-shadow: 0 4px 12px rgba(56, 189, 248, 0.25); flex-shrink: 0; background: #0f172a;">
              <img src="${user.avatar && !user.avatar.includes('dicebear') ? user.avatar : 'data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 64 64\'><circle cx=\'32\' cy=\'32\' r=\'32\' fill=\'%231e293b\'/><circle cx=\'32\' cy=\'24\' r=\'12\' fill=\'%233b82f6\'/><path d=\'M14 52c0-10 8-18 18-18s18 8 18 18\' fill=\'%232563eb\'/></svg>'}" alt="${user.username || 'Player'}" style="width: 100%; height: 100%; object-fit: cover;" referrerpolicy="no-referrer" onerror="this.onerror=null;this.src='data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 64 64\'><circle cx=\'32\' cy=\'32\' r=\'32\' fill=\'%231e293b\'/><circle cx=\'32\' cy=\'24\' r=\'12\' fill=\'%233b82f6\'/><path d=\'M14 52c0-10 8-18 18-18s18 8 18 18\' fill=\'%232563eb\'/></svg>';" />
            </div>

            <!-- User Info -->
            <div style="display: flex; flex-direction: column; gap: 2px;">
              <div style="font-size: 16px; font-weight: 900; color: #0f172a; font-family: var(--font-heading); display: flex; align-items: center; gap: 6px;">
                <span>${user.username || user.fullName || 'MR Mobin'}</span>
                ${isAdmin ? '<span style="background: #dc2626; color: #ffffff; font-size: 9px; font-weight: 800; padding: 2px 6px; border-radius: 10px;">ADMIN</span>' : ''}
              </div>
              <div style="font-size: 11.5px; color: #64748b; font-weight: 500;">
                ${user.email || 'mrmobin444@gmail.com'}
              </div>
              <div style="display: flex; align-items: center; gap: 6px; margin-top: 3px;">
                <span style="background: #0284c7; color: #ffffff; font-size: 9.5px; font-weight: 800; padding: 2px 8px; border-radius: 12px; letter-spacing: 0.3px; display: inline-flex; align-items: center; gap: 3px;">
                  ★ VIP PRO
                </span>
                <span style="background: #f1f5f9; color: #64748b; font-size: 9.5px; font-weight: 700; padding: 2px 6px; border-radius: 6px;">
                  ${playerNumber}
                </span>
              </div>
            </div>
          </div>

          <!-- Edit Profile Info Icon Button -->
          <button id="btn-profile-edit-pencil" title="Edit Profile Details" style="background: #f0f9ff; border: 1px solid #bae6fd; width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center; color: #0284c7; cursor: pointer; transition: all 0.15s ease;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round">
              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
              <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
            </svg>
          </button>
        </div>

        <!-- Free Fire UID Banner Row -->
        <div style="margin-top: 14px; padding-top: 12px; border-top: 1px solid #f1f5f9; display: flex; align-items: center; justify-content: space-between; gap: 10px;">
          <div style="display: flex; align-items: center; gap: 8px;">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0284c7" stroke-width="2">
              <rect x="2" y="6" width="20" height="12" rx="2"></rect>
              <circle cx="6" cy="12" r="1.5" fill="#0284c7"></circle>
              <circle cx="18" cy="12" r="1.5" fill="#0284c7"></circle>
              <path d="M10 12h4"></path>
            </svg>
            <span style="font-size: 12px; font-weight: 700; color: #334155;">Free Fire UID:</span>
            <span id="label-profile-ffuid" style="font-size: 12px; font-weight: 800; color: #0284c7;">${ffUid ? ffUid : '<span style="color:#94a3b8; font-weight:500;">Not Set</span>'}</span>
          </div>

          <button id="btn-set-ffuid" style="background: #0284c7; color: #ffffff; border: none; padding: 6px 14px; border-radius: 20px; font-size: 11px; font-weight: 800; cursor: pointer; display: flex; align-items: center; gap: 4px; box-shadow: 0 2px 6px rgba(2, 132, 199, 0.3);">
            <span>${ffUid ? 'Edit UID ✏️' : 'Set UID +'}</span>
          </button>
        </div>
      </div>

      <!-- 2. Referral Program & Rewards Violet Banner -->
      <div id="banner-profile-referral" style="background: linear-gradient(135deg, #2e0854 0%, #4c1d95 50%, #6d28d9 100%); border-radius: 18px; padding: 14px 16px; color: #ffffff; display: flex; align-items: center; justify-content: space-between; gap: 12px; box-shadow: 0 6px 18px rgba(109, 40, 217, 0.25); cursor: pointer;">
        <div style="display: flex; align-items: center; gap: 12px;">
          <div style="width: 44px; height: 44px; border-radius: 12px; background: rgba(255, 255, 255, 0.15); display: flex; align-items: center; justify-content: center; font-size: 20px; border: 1px solid rgba(255, 255, 255, 0.25); flex-shrink: 0;">
            🎁
          </div>
          <div>
            <div style="font-size: 13.5px; font-weight: 800; letter-spacing: 0.2px;">Referral Program & Rewards</div>
            <div style="font-size: 10.5px; opacity: 0.88; margin-top: 1px;">
              Invite code: <strong style="color: #facc15;">${referralCode}</strong> • Earn diamonds
            </div>
          </div>
        </div>

        <button style="background: #ffffff; color: #6d28d9; border: none; padding: 6px 14px; border-radius: 20px; font-size: 11px; font-weight: 900; letter-spacing: 0.4px; cursor: pointer; flex-shrink: 0; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);">
          INVITE ›
        </button>
      </div>

      <!-- 3. 📊 Esports Performance & Stats (3 Cards) -->
      <div>
        <div style="font-size: 12.5px; font-weight: 800; color: #0f172a; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
          <span>📊 Esports Performance & Stats</span>
        </div>

        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px;">
          <!-- Tournaments -->
          <div class="stat-bubble-card" id="p-stat-tournaments" style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; padding: 14px 8px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 4px; box-shadow: 0 2px 6px rgba(0,0,0,0.02); cursor: pointer;">
            <div style="font-size: 20px;">🏆</div>
            <div style="font-size: 18px; font-weight: 900; color: #0f172a; font-family: var(--font-heading);">${tournamentsJoined}</div>
            <div style="font-size: 9.5px; font-weight: 700; color: #64748b;">Tournaments</div>
          </div>

          <!-- Downloads -->
          <div class="stat-bubble-card" id="p-stat-downloads" style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; padding: 14px 8px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 4px; box-shadow: 0 2px 6px rgba(0,0,0,0.02); cursor: pointer;">
            <div style="font-size: 20px;">📥</div>
            <div style="font-size: 18px; font-weight: 900; color: #0f172a; font-family: var(--font-heading);">${totalDownloads}</div>
            <div style="font-size: 9.5px; font-weight: 700; color: #64748b;">Downloads</div>
          </div>

          <!-- Sensitivities -->
          <div class="stat-bubble-card" id="p-stat-sensitivities" style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; padding: 14px 8px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 4px; box-shadow: 0 2px 6px rgba(0,0,0,0.02); cursor: pointer;">
            <div style="font-size: 20px;">🎯</div>
            <div style="font-size: 18px; font-weight: 900; color: #0f172a; font-family: var(--font-heading);">${savedSens.length}</div>
            <div style="font-size: 9.5px; font-weight: 700; color: #64748b;">Sensitivities</div>
          </div>
        </div>
      </div>

      <!-- 4. 🎯 Quick Actions & Features -->
      <div>
        <div style="font-size: 12.5px; font-weight: 800; color: #0f172a; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
          <span>🎯 Quick Actions & Features</span>
        </div>

        <div style="background: #ffffff; border-radius: 18px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 2px 6px rgba(0,0,0,0.02);">
          
          <!-- Tournaments -->
          <div class="profile-feature-row" id="p-menu-tournaments" style="padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #f1f5f9; cursor: pointer;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="font-size: 18px;">🏆</div>
              <div>
                <div style="font-size: 13px; font-weight: 800; color: #0f172a;">My Tournaments & Matches</div>
                <div style="font-size: 10.5px; color: #64748b;">View joined rooms, match schedules & prize claim status</div>
              </div>
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
          </div>

          <!-- Sensitivity Maker -->
          <div class="profile-feature-row" id="p-menu-sensitivities" style="padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #f1f5f9; cursor: pointer;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="font-size: 18px;">🎛️</div>
              <div>
                <div style="font-size: 13px; font-weight: 800; color: #0f172a;">Saved Aim Presets & Sensitivity Maker</div>
                <div style="font-size: 10.5px; color: #64748b;">Calibrate your phone for 100% headshot accuracy</div>
              </div>
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
          </div>

          <!-- Referral Program -->
          <div class="profile-feature-row" id="p-menu-referral" style="padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; cursor: pointer;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="font-size: 18px;">🎁</div>
              <div>
                <div style="font-size: 13px; font-weight: 800; color: #0f172a;">Referral Program & Rewards</div>
                <div style="font-size: 10.5px; color: #64748b;">Invite friends, earn diamonds & instant bKash rewards</div>
              </div>
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
          </div>

        </div>
      </div>

      <!-- 5. ⚙️ Account Settings -->
      <div>
        <div style="font-size: 12.5px; font-weight: 800; color: #0f172a; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
          <span>⚙️ Account Settings</span>
        </div>

        <div style="background: #ffffff; border-radius: 18px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 2px 6px rgba(0,0,0,0.02);">
          
          <!-- Master Admin Console (Visible if Admin) -->
          ${isAdmin ? `
            <div class="profile-feature-row" id="p-menu-admin-console" style="padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #f1f5f9; background: #f0fdf4; cursor: pointer;">
              <div style="display: flex; align-items: center; gap: 12px;">
                <div style="font-size: 18px;">👑</div>
                <div>
                  <div style="font-size: 13px; font-weight: 800; color: #15803d;">Master Admin Console</div>
                  <div style="font-size: 10.5px; color: #166534;">Control tournaments, room IDs, APK catalog & push alerts</div>
                </div>
              </div>
              <span style="background: #16a34a; color: #ffffff; font-size: 9.5px; font-weight: 800; padding: 2px 8px; border-radius: 10px;">OPEN</span>
            </div>
          ` : ''}

          <!-- App Settings & Preferences -->
          <div class="profile-feature-row" id="p-menu-settings" style="padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #f1f5f9; cursor: pointer;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="font-size: 18px;">⚙️</div>
              <div>
                <div style="font-size: 13px; font-weight: 800; color: #0f172a;">App Settings & Preferences</div>
                <div style="font-size: 10.5px; color: #64748b;">Push notifications, sound alerts & cache manager</div>
              </div>
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
          </div>

          <!-- Help & Support 24/7 -->
          <div class="profile-feature-row" id="p-menu-support" style="padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #f1f5f9; cursor: pointer;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="font-size: 18px;">🎧</div>
              <div>
                <div style="font-size: 13px; font-weight: 800; color: #0f172a;">Help & Support 24/7</div>
                <div style="font-size: 10.5px; color: #64748b;">WhatsApp, Telegram, live tickets & FAQs</div>
              </div>
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
          </div>

          <!-- About Mobin X -->
          <div class="profile-feature-row" id="p-menu-about" style="padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #f1f5f9; cursor: pointer;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="font-size: 18px;">ℹ️</div>
              <div>
                <div style="font-size: 13px; font-weight: 800; color: #0f172a;">About Mobin X</div>
                <div style="font-size: 10.5px; color: #64748b;">Version details, studio credits & security shield</div>
              </div>
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
          </div>

          <!-- Sign Out -->
          <div class="profile-feature-row" id="p-menu-logout" style="padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; cursor: pointer;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="font-size: 18px;">🚪</div>
              <div>
                <div style="font-size: 13px; font-weight: 800; color: #dc2626;">Sign Out</div>
                <div style="font-size: 10.5px; color: #64748b;">Logout from this Android device</div>
              </div>
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
          </div>

        </div>
      </div>

    </div>

    <!-- Free Fire UID Setup Modal -->
    <div id="modal-set-ffuid" class="modal-overlay" style="display: none; position: fixed; inset: 0; background: rgba(0, 0, 0, 0.7); backdrop-filter: blur(6px); z-index: 9999; align-items: center; justify-content: center; padding: 20px;">
      <div style="background: #ffffff; border-radius: 24px; padding: 24px 20px; width: 100%; max-width: 360px; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3); text-align: center;">
        <div style="width: 52px; height: 52px; border-radius: 50%; background: #e0f2fe; color: #0284c7; display: flex; align-items: center; justify-content: center; font-size: 24px; margin: 0 auto 12px auto;">
          🎮
        </div>
        <h3 style="font-size: 17px; font-weight: 900; color: #0f172a; margin: 0 0 6px 0;">Set Free Fire Player UID</h3>
        <p style="font-size: 12px; color: #64748b; line-height: 1.4; margin: 0 0 16px 0;">
          Your UID is used to automatically verify tournament registrations and deliver rewards.
        </p>

        <div style="margin-bottom: 16px; text-align: left;">
          <label style="font-size: 11.5px; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Free Fire UID Number</label>
          <input type="text" id="input-modal-ffuid" placeholder="e.g. 1928374650" value="${ffUid || ''}" style="width: 100%; height: 44px; border: 1.5px solid #cbd5e1; border-radius: 12px; padding: 0 12px; font-size: 14px; font-weight: 700; outline: none; box-sizing: border-box;" />
        </div>

        <div style="display: flex; gap: 10px;">
          <button id="btn-cancel-ffuid" style="flex: 1; height: 44px; background: #f1f5f9; border: none; border-radius: 12px; font-size: 13px; font-weight: 700; color: #475569; cursor: pointer;">
            Cancel
          </button>
          <button id="btn-save-ffuid" style="flex: 1.2; height: 44px; background: #0284c7; border: none; border-radius: 12px; font-size: 13.5px; font-weight: 800; color: #ffffff; cursor: pointer; box-shadow: 0 4px 12px rgba(2, 132, 199, 0.35);">
            Save UID
          </button>
        </div>
      </div>
    </div>
  `;
}

export function bindProfileEvents() {
  // Free Fire UID Modal Handlers
  const modalUid = document.getElementById('modal-set-ffuid');
  document.getElementById('btn-set-ffuid')?.addEventListener('click', () => {
    if (modalUid) modalUid.style.display = 'flex';
  });

  document.getElementById('btn-cancel-ffuid')?.addEventListener('click', () => {
    if (modalUid) modalUid.style.display = 'none';
  });

  document.getElementById('btn-save-ffuid')?.addEventListener('click', async () => {
    const val = document.getElementById('input-modal-ffuid')?.value.trim();
    if (!val) {
      Toast.show('Please enter your Free Fire UID', 'warning');
      return;
    }

    const updatedUser = authService.updateUserProfile({ ffUid: val, freeFireUid: val });
    try {
      if (firebaseService && typeof firebaseService.saveToFirestore === 'function' && updatedUser.id) {
        await firebaseService.saveToFirestore('users', updatedUser.id, updatedUser);
      }
    } catch (e) {}

    Toast.show(`Free Fire UID saved: ${val}`, 'success');
    if (modalUid) modalUid.style.display = 'none';
    stateManager.navigate('profile');
  });

  // Edit profile pencil icon
  document.getElementById('btn-profile-edit-pencil')?.addEventListener('click', () => {
    resetOnboardingStep('auth-hub');
    stateManager.navigate('onboarding');
  });

  // Referral banner & menu click
  document.getElementById('banner-profile-referral')?.addEventListener('click', () => {
    stateManager.navigate('referral');
  });
  document.getElementById('p-menu-referral')?.addEventListener('click', () => {
    stateManager.navigate('referral');
  });

  // Stat cards navigation
  document.getElementById('p-stat-tournaments')?.addEventListener('click', () => {
    stateManager.navigate('tournaments');
  });
  document.getElementById('p-stat-downloads')?.addEventListener('click', () => {
    stateManager.navigate('downloads');
  });
  document.getElementById('p-stat-sensitivities')?.addEventListener('click', () => {
    stateManager.navigate('sensitivity');
  });

  // Feature menu rows
  document.getElementById('p-menu-tournaments')?.addEventListener('click', () => {
    stateManager.navigate('tournaments');
  });
  document.getElementById('p-menu-sensitivities')?.addEventListener('click', () => {
    stateManager.navigate('sensitivity');
  });

  // Admin console
  document.getElementById('p-menu-admin-console')?.addEventListener('click', () => {
    stateManager.navigate('admin');
  });

  // Settings & Preferences
  document.getElementById('p-menu-settings')?.addEventListener('click', () => {
    stateManager.navigate('settings');
  });

  // 24/7 Support
  document.getElementById('p-menu-support')?.addEventListener('click', () => {
    const urls = authService.getUrls();
    const telegramUrl = urls.telegram || 'https://t.me/mrmobin1m';
    Toast.show('Connecting to Official 24/7 Support...', 'info');
    window.open(telegramUrl, '_blank');
  });

  // About Mobin X
  document.getElementById('p-menu-about')?.addEventListener('click', () => {
    stateManager.navigate('about');
  });

  // Logout / Sign Out
  document.getElementById('p-menu-logout')?.addEventListener('click', () => {
    if (confirm('Are you sure you want to sign out from this device?')) {
      authService.logout();
      resetOnboardingStep('welcome');
      Toast.show('Signed out successfully.', 'info');
      stateManager.navigate('onboarding');
    }
  });
}
