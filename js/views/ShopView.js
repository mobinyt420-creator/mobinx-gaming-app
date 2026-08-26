import { APP_CONFIG_URLS } from '../config/urls.js';
import { stateManager } from '../services/stateManager.js';
import { authService } from '../services/authService.js';

export function renderShopView() {
  const urls = authService.getUrls();
  const targetUrl = urls.shop || APP_CONFIG_URLS.SHOP_URL || 'https://www.obinshop.com/';

  return `
    <div class="view-container in-app-direct-webview" style="height: 100%; width: 100%; display: flex; flex-direction: column; overflow: hidden; background: #0f172a;">
      <!-- Webview Control Bar -->
      <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 14px; background: #0b1329; border-bottom: 1px solid rgba(255,255,255,0.1); flex-shrink: 0; z-index: 30;">
        <button id="btn-shop-back-home" style="display: flex; align-items: center; gap: 6px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); color: #ffffff; padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 700; cursor: pointer;">
          <span>◀</span>
          <span>Back to App</span>
        </button>

        <div style="display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 800; color: #a855f7;">
          <span>🛍️</span>
          <span>ObinShop Official</span>
        </div>

        <div style="display: flex; gap: 6px; align-items: center;">
          <button id="btn-shop-reload" title="Refresh Page" style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); color: #ffffff; width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; cursor: pointer; font-size: 13px;">
            🔄
          </button>
          <a href="${targetUrl}" target="_blank" rel="noopener noreferrer" title="Open in External Browser" style="background: rgba(168,85,247,0.25); border: 1px solid #a855f7; color: #c084fc; width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; text-decoration: none; font-size: 13px;">
            🌐
          </a>
        </div>
      </div>

      <iframe 
        src="${targetUrl}" 
        id="shop-webview-iframe" 
        class="direct-fullscreen-iframe"
        title="ObinShop Store"
        allow="payment; camera; microphone; geolocation; clipboard-read; clipboard-write; autoplay; fullscreen"
        loading="eager"
        style="width: 100%; height: 100%; border: none; display: block; flex: 1; background: #ffffff;">
      </iframe>
    </div>
  `;
}

export function bindShopEvents() {
  document.getElementById('btn-shop-back-home')?.addEventListener('click', () => {
    stateManager.navigate('home');
  });

  document.getElementById('btn-shop-reload')?.addEventListener('click', () => {
    const iframe = document.getElementById('shop-webview-iframe');
    if (iframe) {
      const currentSrc = iframe.src;
      iframe.src = '';
      setTimeout(() => { iframe.src = currentSrc; }, 50);
    }
  });
}
