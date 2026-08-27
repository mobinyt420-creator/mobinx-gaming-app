import { authService } from '../services/authService.js';
import { firebaseService } from '../services/firebaseService.js';
import { stateManager } from '../services/stateManager.js';
import { Toast } from '../components/Toast.js';
import { resetOnboardingStep } from './OnboardingView.js';

export function renderProfileView() {
  const user = authService.getCurrentUser() || {};
  const isAdmin = authService.isAdmin();
  const savedSens = authService.getSavedSensitivities() || [];
  const stats = user.stats || {};
  const tournamentsJoined = stats.tournamentsJoined ?? 0;
  const totalDownloads = stats.totalDownloads ?? 0;
  const referralEarnings = user.referralEarnings ?? 0;

  return `
    <div class="view-container profile-view">
      <!-- Profile Hero Card -->
      <div class="profile-hero" style="${isAdmin ? 'background: linear-gradient(135deg, #1e1b4b 0%, #1e3a8a 50%, #7c3aed 100%);' : ''}">
        <div class="profile-avatar-large">
          <img src="${user.avatar || 'assets/images/avatar_user.jpg'}" alt="${user.username || 'Player'}" referrerpolicy="no-referrer" onerror="this.src='assets/images/avatar_user.jpg'" />
        </div>
        <div class="profile-username">
          <span>${user.username || user.fullName || 'Player'}</span>
          ${isAdmin ? '<span class="badge badge-danger" style="font-size: 10px; margin-left: 4px;">ADMIN</span>' : '<span style="font-size: 16px; color: #60a5fa;">✓</span>'}
        </div>
        <div style="font-size: 11.5px; opacity: 0.9;">${user.email || 'Gamer Account'}</div>
        <div class="profile-uid-pill">ID: ${user.id || user.userId || 'MX-USER'} • ${user.role || 'Member'}</div>

        <!-- Google Login / Switch Account & Edit Name/Phone -->
        <div style="display: flex; gap: 8px; justify-content: center; flex-wrap: wrap; margin-top: 8px;">
          <button class="btn-secondary" id="btn-profile-google-login" style="padding: 6px 14px; font-size: 11.5px; border-radius: var(--radius-full); background: rgba(255,255,255,0.95); cursor: pointer; display: inline-flex; align-items: center;">
            <svg width="14" height="14" viewBox="0 0 24 24" style="margin-right: 4px;"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/></svg>
            <span>Sign In / Switch Gmail</span>
          </button>
          <button class="btn-secondary" id="btn-profile-edit-info" style="padding: 6px 14px; font-size: 11.5px; border-radius: var(--radius-full); background: rgba(255,255,255,0.22); color: #ffffff; border: 1px solid rgba(255,255,255,0.4); cursor: pointer; display: inline-flex; align-items: center;">
            <span>📝 Setup Name & Phone</span>
          </button>
        </div>
      </div>

      <!-- 4 Stats Bar -->
      <div class="profile-stats-bar">
        <div class="p-stat-item">
          <span class="p-stat-value">${tournamentsJoined}</span>
          <span class="p-stat-label">Tournaments</span>
        </div>
        <div class="p-stat-item">
          <span class="p-stat-value">${totalDownloads}</span>
          <span class="p-stat-label">Downloads</span>
        </div>
        <div class="p-stat-item">
          <span class="p-stat-value">${savedSens.length}</span>
          <span class="p-stat-label">Saved Sens</span>
        </div>
        <div class="p-stat-item">
          <span class="p-stat-value" style="color: var(--success);">$${referralEarnings}</span>
          <span class="p-stat-label">Earnings</span>
        </div>
      </div>

      <!-- Profile Menu Section -->
      <div class="profile-menu-section">



        <div class="profile-menu-item" id="p-menu-tournaments">
          <div class="profile-item-left">
            <div class="profile-item-icon" style="background: #fffbeb; color: #f59e0b;">🏆</div>
            <span>My Tournaments & Matches</span>
          </div>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>

        <div class="profile-menu-item" id="p-menu-sensitivities">
          <div class="profile-item-left">
            <div class="profile-item-icon" style="background: #eff6ff; color: #2563eb;">🎯</div>
            <span>Saved Aim Presets (${savedSens.length})</span>
          </div>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>

        <div class="profile-menu-item" id="p-menu-downloads">
          <div class="profile-item-left">
            <div class="profile-item-icon" style="background: #ecfdf5; color: #10b981;">📥</div>
            <span>Downloaded Files & Tools</span>
          </div>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>

        <div class="profile-menu-item" id="p-menu-referral">
          <div class="profile-item-left">
            <div class="profile-item-icon" style="background: #f5f3ff; color: #7c3aed;">🎁</div>
            <span>Referral Program & Rewards</span>
          </div>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>

        <div class="profile-menu-item" id="p-menu-settings">
          <div class="profile-item-left">
            <div class="profile-item-icon" style="background: #f1f5f9; color: #475569;">⚙️</div>
            <span>Account Settings</span>
          </div>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>

        <!-- 24/7 Official Live Support (Telegram / WhatsApp) -->
        <div class="profile-menu-item" id="p-menu-support" style="background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 100%); border: 1.5px solid #a7f3d0;">
          <div class="profile-item-left">
            <div class="profile-item-icon" style="background: #10b981; color: #ffffff;">🎧</div>
            <div>
              <div style="color: #065f46; font-weight: 800;">24/7 Official Support</div>
              <div style="font-size: 10.5px; color: #047857;">Telegram & WhatsApp Help Desk</div>
            </div>
          </div>
          <span style="background: #10b981; color: #ffffff; font-size: 10.5px; font-weight: 800; padding: 4px 10px; border-radius: 20px;">
            CHAT →
          </span>
        </div>

        <div class="profile-menu-item" id="p-menu-help">
          <div class="profile-item-left">
            <div class="profile-item-icon" style="background: #f0fdfa; color: #0d9488;">💬</div>
            <span>Help Center & FAQs</span>
          </div>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>

        <div class="profile-menu-item" id="p-menu-onboarding-preview">
          <div class="profile-item-left">
            <div class="profile-item-icon" style="background: #eff6ff; color: #2563eb;">📱</div>
            <span>Welcome / Onboarding Screen</span>
          </div>
          <span class="badge badge-primary">PREVIEW</span>
        </div>

        <div class="profile-menu-item" id="p-menu-logout" style="border-color: rgba(239, 68, 68, 0.2);">
          <div class="profile-item-left">
            <div class="profile-item-icon" style="background: #fef2f2; color: #ef4444;">🚪</div>
            <span style="color: var(--danger);">Reset / Logout Session</span>
          </div>
        </div>
      </div>
    </div>
  `;
}

export function bindProfileEvents() {
  document.getElementById('btn-profile-edit-info')?.addEventListener('click', () => {
    resetOnboardingStep(2);
    stateManager.navigate('onboarding');
  });

  document.getElementById('btn-profile-google-login')?.addEventListener('click', async () => {
    try {
      Toast.show('Opening Google Account Picker...', 'info');
      const googleUser = await firebaseService.signInWithGoogle();
      if (googleUser && googleUser.email) {
        const user = await authService.loginWithGoogle(
          googleUser.email, 
          googleUser.displayName, 
          '', 
          '', 
          googleUser.photoURL || ''
        );
        Toast.show(`Welcome back, ${user.username}!`, 'success');
        stateManager.navigate('profile');
      }
    } catch (err) {
      console.warn('Profile Google Login error:', err);
      Toast.show(err.message || 'Google Sign-In was cancelled', 'warning');
    }
  });

  document.getElementById('p-menu-support')?.addEventListener('click', () => {
    const urls = authService.getUrls();
    const telegramUrl = urls.telegram || 'https://t.me/mrmobin1m';
    Toast.show('Connecting to Official 24/7 Support Desk...', 'info');
    window.open(telegramUrl, '_blank');
  });

  document.getElementById('p-menu-onboarding-preview')?.addEventListener('click', () => {
    resetOnboardingStep(2);
    stateManager.navigate('onboarding');
  });

  document.getElementById('p-menu-tournaments')?.addEventListener('click', () => {
    stateManager.navigate('tournaments');
  });

  document.getElementById('p-menu-sensitivities')?.addEventListener('click', () => {
    const saved = authService.getSavedSensitivities();
    if (saved.length === 0) {
      Toast.show('No saved sensitivity presets yet. Generate one in Sensitivity Maker!', 'info');
      stateManager.navigate('sensitivity');
    } else {
      Toast.show(`You have ${saved.length} saved presets in vault.`, 'success');
      stateManager.navigate('sensitivity');
    }
  });

  document.getElementById('p-menu-downloads')?.addEventListener('click', () => {
    stateManager.navigate('downloads');
  });

  document.getElementById('p-menu-referral')?.addEventListener('click', () => {
    stateManager.navigate('referral');
  });

  document.getElementById('p-menu-settings')?.addEventListener('click', () => {
    stateManager.navigate('settings');
  });

  document.getElementById('p-menu-help')?.addEventListener('click', () => {
    stateManager.navigate('help');
  });

  document.getElementById('p-menu-logout')?.addEventListener('click', () => {
    authService.logout();
    resetOnboardingStep(2);
    Toast.show('Logged out successfully. Enter details to login.', 'info');
    stateManager.navigate('onboarding');
  });
}
