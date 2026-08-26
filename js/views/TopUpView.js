import { APP_CONFIG_URLS } from '../config/urls.js';
import { stateManager } from '../services/stateManager.js';
import { authService } from '../services/authService.js';

let isBrowserOpening = false;

// Safely access Capacitor Browser from window object (No bare imports that break webview!)
function getCapacitorBrowser() {
  if (typeof window !== 'undefined' && window.Capacitor?.Plugins?.Browser) {
    return window.Capacitor.Plugins.Browser;
  }
  return null;
}

export async function openTopUpCustomTab() {
  if (isBrowserOpening) return;
  isBrowserOpening = true;

  const urls = authService.getUrls();
  const targetUrl = urls.topup || APP_CONFIG_URLS.TOPUP_URL || 'https://noobtopup.com/';

  try {
    const nativeBrowser = getCapacitorBrowser();
    if (nativeBrowser) {
      // In native Android APK: Opens Chrome Custom Tabs with full Google login & bKash
      await nativeBrowser.open({
        url: targetUrl,
        toolbarColor: '#0284c7',
        presentationStyle: 'fullscreen'
      });
      return;
    }
  } catch (err) {
    console.warn('Capacitor Browser notice:', err);
  } finally {
    setTimeout(() => { isBrowserOpening = false; }, 1000);
  }

  // Fallback for PC browser or standard web: opens in new window
  window.open(targetUrl, '_blank');
}

export function renderTopUpView() {
  return `
    <div class="view-container" style="min-height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 28px 20px; text-align: center; background: #080c14; color: #ffffff;">
      
      <div style="width: 80px; height: 80px; border-radius: 24px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 30px rgba(2, 132, 199, 0.45); margin-bottom: 18px; border: 2px solid rgba(56, 189, 248, 0.3);">
        <span style="font-size: 38px;">💎</span>
      </div>

      <h2 style="font-size: 22px; font-weight: 900; margin: 0 0 8px 0; font-family: var(--font-heading);">
        NoobTopUp Diamond Store
      </h2>
      <p style="font-size: 13px; color: #94a3b8; max-width: 320px; margin: 0 0 24px 0; line-height: 1.5;">
        Opening secure In-App Custom Browser. Instant Diamond delivery with 100% Google Sign-In & bKash automated checkout.
      </p>

      <div style="display: flex; flex-direction: column; gap: 12px; width: 100%; max-width: 280px;">
        <button id="btn-reopen-topup" style="padding: 14px 20px; background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%); color: #ffffff; border: none; border-radius: 12px; font-size: 14px; font-weight: 800; cursor: pointer; box-shadow: 0 6px 18px rgba(2, 132, 199, 0.4); display: flex; align-items: center; justify-content: center; gap: 8px;">
          <span>💎 Open Top-Up Store Now</span>
        </button>

        <button id="btn-topup-back-home" style="padding: 13px 20px; background: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.15); color: #ffffff; border-radius: 12px; font-size: 13.5px; font-weight: 700; cursor: pointer;">
          ◀ Return to App Home
        </button>
      </div>

    </div>
  `;
}

export function bindTopUpEvents() {
  // Automatically open the Chrome Custom Tab immediately when entering view
  openTopUpCustomTab();

  document.getElementById('btn-reopen-topup')?.addEventListener('click', () => {
    openTopUpCustomTab();
  });

  document.getElementById('btn-topup-back-home')?.addEventListener('click', () => {
    stateManager.navigate('home');
  });

  // When user closes the Chrome Custom Tab (taps the X button), navigate cleanly back to Home
  try {
    const nativeBrowser = getCapacitorBrowser();
    if (nativeBrowser?.removeAllListeners) {
      nativeBrowser.removeAllListeners();
      nativeBrowser.addListener('browserFinished', () => {
        stateManager.navigate('home');
      });
    }
  } catch (e) {}
}
