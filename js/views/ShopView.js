import { Browser } from '@capacitor/browser';
import { APP_CONFIG_URLS } from '../config/urls.js';
import { stateManager } from '../services/stateManager.js';
import { authService } from '../services/authService.js';

let isShopOpening = false;

export async function openShopCustomTab() {
  if (isShopOpening) return;
  isShopOpening = true;

  const urls = authService.getUrls();
  const targetUrl = urls.shop || APP_CONFIG_URLS.SHOP_URL || 'https://www.obinshop.com/';

  try {
    // Open in native Chrome Custom Tab
    await Browser.open({
      url: targetUrl,
      toolbarColor: '#7c3aed',
      presentationStyle: 'fullscreen'
    });
  } catch (err) {
    console.warn('Capacitor Browser fallback:', err);
    window.open(targetUrl, '_blank');
  } finally {
    setTimeout(() => { isShopOpening = false; }, 1000);
  }
}

export function renderShopView() {
  return `
    <div class="view-container" style="min-height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 28px 20px; text-align: center; background: #080c14; color: #ffffff;">
      
      <div style="width: 80px; height: 80px; border-radius: 24px; background: linear-gradient(135deg, #7c3aed 0%, #2563eb 100%); display: flex; align-items: center; justify-content: center; box-shadow: 0 10px 30px rgba(124, 58, 237, 0.45); margin-bottom: 18px; border: 2px solid rgba(168, 85, 247, 0.3);">
        <span style="font-size: 38px;">🛍️</span>
      </div>

      <h2 style="font-size: 22px; font-weight: 900; margin: 0 0 8px 0; font-family: var(--font-heading);">
        ObinShop Official Store
      </h2>
      <p style="font-size: 13px; color: #94a3b8; max-width: 320px; margin: 0 0 24px 0; line-height: 1.5;">
        Opening secure In-App Custom Browser with full account login and instant delivery.
      </p>

      <div style="display: flex; flex-direction: column; gap: 12px; width: 100%; max-width: 280px;">
        <button id="btn-reopen-shop" style="padding: 14px 20px; background: linear-gradient(135deg, #7c3aed 0%, #2563eb 100%); color: #ffffff; border: none; border-radius: 12px; font-size: 14px; font-weight: 800; cursor: pointer; box-shadow: 0 6px 18px rgba(124, 58, 237, 0.4); display: flex; align-items: center; justify-content: center; gap: 8px;">
          <span>🛍️ Open ObinShop Store Now</span>
        </button>

        <button id="btn-shop-back-home" style="padding: 13px 20px; background: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.15); color: #ffffff; border-radius: 12px; font-size: 13.5px; font-weight: 700; cursor: pointer;">
          ◀ Return to App Home
        </button>
      </div>

    </div>
  `;
}

export function bindShopEvents() {
  // Automatically open the Chrome Custom Tab immediately when tapped
  openShopCustomTab();

  document.getElementById('btn-reopen-shop')?.addEventListener('click', () => {
    openShopCustomTab();
  });

  document.getElementById('btn-shop-back-home')?.addEventListener('click', () => {
    stateManager.navigate('home');
  });

  try {
    Browser.removeAllListeners();
    Browser.addListener('browserFinished', () => {
      stateManager.navigate('home');
    });
  } catch (e) {}
}
