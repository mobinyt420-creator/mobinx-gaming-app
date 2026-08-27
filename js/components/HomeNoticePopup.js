import { authService } from '../services/authService.js';
import { stateManager } from '../services/stateManager.js';
import { openExternalStore } from '../services/browserService.js';

export function renderHomeNoticePopup() {
  const popup = authService.getHomeNoticePopup();
  const updateConfig = authService.getAppUpdateConfig();

  // 1. Check if App Update is available
  const isUpdateAvailable = (updateConfig && updateConfig.latestVersion && updateConfig.latestVersion !== updateConfig.currentVersion);
  if (isUpdateAvailable) {
    return `
      <div id="home-notice-popup-overlay" style="position: fixed; inset: 0; background: rgba(0, 0, 0, 0.75); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); z-index: 10000; display: flex; align-items: center; justify-content: center; padding: 20px; animation: fadeIn 0.25s ease;">
        <div style="background: #ffffff; border-radius: 24px; overflow: hidden; width: 100%; max-width: 340px; box-shadow: 0 25px 60px rgba(0, 0, 0, 0.4); text-align: center; border: 1px solid rgba(255, 255, 255, 0.3); animation: scaleUp 0.25s cubic-bezier(0.16, 1, 0.3, 1);">
          
          <div style="background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); padding: 28px 20px; color: #ffffff; display: flex; flex-direction: column; align-items: center;">
            <div style="width: 58px; height: 58px; border-radius: 18px; background: rgba(255, 255, 255, 0.2); backdrop-filter: blur(6px); display: flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 12px; border: 1.5px solid rgba(255, 255, 255, 0.4);">
              🚀
            </div>
            <h3 style="font-size: 18px; font-weight: 900; margin: 0 0 4px 0; color: #ffffff;">${updateConfig.updateTitle || 'নতুন আপডেট উপলব্ধ!'}</h3>
            <span style="font-size: 12px; opacity: 0.9; background: rgba(255, 255, 255, 0.2); padding: 2px 10px; border-radius: 12px; font-weight: 700;">Version ${updateConfig.latestVersion}</span>
          </div>

          <div style="padding: 18px 20px 22px 20px;">
            <p style="font-size: 13.5px; font-weight: 600; color: #334155; line-height: 1.5; margin: 0 0 18px 0; text-align: center;">
              ${updateConfig.updateMessage || 'অ্যাপের নতুন ফিচার ও সর্বোত্তম অভিজ্ঞতার জন্য গুগল প্লে স্টোর থেকে এখনই আপডেট করে নিন।'}
            </p>

            <button id="btn-popup-update-now" style="width: 100%; height: 46px; background: linear-gradient(135deg, #0284c7 0%, #0066ff 100%); color: #ffffff; border: none; border-radius: 12px; font-size: 14.5px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 6px 18px rgba(2, 132, 199, 0.35);">
              <span>Play Store থেকে আপডেট করুন</span>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
            </button>

            ${!updateConfig.forceUpdate ? `
              <button id="btn-popup-close" style="background: transparent; color: #64748b; border: none; font-size: 12.5px; font-weight: 700; cursor: pointer; margin-top: 14px; padding: 6px 14px;">
                পরে মনে করিয়ে দিন
              </button>
            ` : ''}
          </div>

        </div>
      </div>
    `;
  }

  // 2. Check if Home Promotional / Notice Popup is enabled
  if (!popup || !popup.enabled) return '';

  // Check if dismissed this session
  if (popup.showOncePerSession && typeof sessionStorage !== 'undefined' && sessionStorage.getItem('mobinx_popup_dismissed')) {
    return '';
  }

  return `
    <div id="home-notice-popup-overlay" style="position: fixed; inset: 0; background: rgba(0, 0, 0, 0.72); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); z-index: 10000; display: flex; align-items: center; justify-content: center; padding: 20px; animation: fadeIn 0.25s ease;">
      <div style="background: #ffffff; border-radius: 20px; overflow: hidden; width: 100%; max-width: 340px; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4); text-align: center; border: 1px solid rgba(255, 255, 255, 0.25); animation: scaleUp 0.25s cubic-bezier(0.16, 1, 0.3, 1);">
        
        <!-- Top Image Banner (if provided) -->
        ${popup.image ? `
          <div style="width: 100%; max-height: 220px; overflow: hidden; background: #0f172a; position: relative;">
            <img src="${popup.image}" alt="Notice Banner" style="width: 100%; height: 100%; max-height: 220px; object-fit: cover; display: block;" onerror="this.style.display='none'" />
          </div>
        ` : ''}

        <div style="padding: 16px 18px 20px 18px;">
          <!-- Description / Message in Bengali/English -->
          <p style="font-size: 14px; font-weight: 700; color: #0f172a; line-height: 1.5; margin: 0 0 16px 0; text-align: left;">
            ${popup.description || popup.title || 'অল্প দামে ১৮ মাসের জন্য Google ai Pro নিতে চাইলে নিচের বাটনে ক্লিক করে আমাদের সাথে যোগাযোগ করুন।'}
          </p>

          <!-- Primary Action Button -->
          <div style="display: flex; justify-content: flex-start;">
            <button id="btn-popup-action" style="background: #0284c7; color: #ffffff; border: none; border-radius: 8px; padding: 9px 22px; font-size: 14px; font-weight: 800; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 4px 12px rgba(2, 132, 199, 0.35); transition: transform 0.15s ease;">
              <span>${popup.buttonText || 'ক্লিক করুন'}</span>
            </button>
          </div>

          <!-- Bottom Close Button (Matching Screenshot exactly: ✗ CLOSE in vibrant blue pill) -->
          <div style="display: flex; justify-content: center; margin-top: 18px;">
            <button id="btn-popup-close" style="background: #0084ff; color: #ffffff; border: none; border-radius: 30px; padding: 9px 36px; font-size: 13px; font-weight: 800; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 6px; box-shadow: 0 4px 16px rgba(0, 132, 255, 0.4); letter-spacing: 0.5px; transition: transform 0.15s ease;">
              <span>✗ CLOSE</span>
            </button>
          </div>
        </div>

      </div>
    </div>
  `;
}

export function bindHomeNoticePopupEvents() {
  const overlay = document.getElementById('home-notice-popup-overlay');
  if (!overlay) return;

  const popup = authService.getHomeNoticePopup();
  const updateConfig = authService.getAppUpdateConfig();

  function dismissPopup() {
    if (typeof sessionStorage !== 'undefined') {
      sessionStorage.setItem('mobinx_popup_dismissed', 'true');
    }
    overlay.style.opacity = '0';
    overlay.style.transition = 'opacity 0.2s ease';
    setTimeout(() => {
      overlay.remove();
    }, 200);
  }

  // Close Button Click
  document.getElementById('btn-popup-close')?.addEventListener('click', () => {
    dismissPopup();
  });

  // Background overlay click to close (optional)
  overlay.addEventListener('click', (e) => {
    if (e.target.id === 'home-notice-popup-overlay' && !updateConfig.forceUpdate) {
      dismissPopup();
    }
  });

  // Action Button Click
  document.getElementById('btn-popup-action')?.addEventListener('click', () => {
    dismissPopup();
    const url = popup.buttonUrl || 'https://t.me/mrmobin1m';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      openExternalStore(url, '#0284c7');
    } else {
      stateManager.navigate(url);
    }
  });

  // App Update Button Click
  document.getElementById('btn-popup-update-now')?.addEventListener('click', () => {
    const playStoreUrl = updateConfig.updateUrl || 'https://play.google.com/store/apps/details?id=com.mobinx.gaming';
    openExternalStore(playStoreUrl, '#0284c7');
    dismissPopup();
  });
}
