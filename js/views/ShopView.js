import { APP_CONFIG_URLS } from '../config/urls.js';
import { stateManager } from '../services/stateManager.js';
import { authService } from '../services/authService.js';

export function renderShopView() {
  const urls = authService.getUrls();
  const targetUrl = urls.shop || APP_CONFIG_URLS.SHOP_URL || 'https://www.obinshop.com/';

  return `
    <div class="view-container in-app-direct-webview" style="height: 100%; width: 100%; display: flex; flex-direction: column; overflow: hidden; background: #ffffff;">
      <iframe 
        src="${targetUrl}" 
        id="shop-webview-iframe" 
        class="direct-fullscreen-iframe"
        title="ObinShop Store"
        sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-modals"
        loading="eager"
        style="width: 100%; height: 100%; border: none; display: block; flex: 1;">
      </iframe>
    </div>
  `;
}

export function bindShopEvents() {
  // Main header handles navigation
}


