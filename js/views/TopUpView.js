import { APP_CONFIG_URLS } from '../config/urls.js';
import { stateManager } from '../services/stateManager.js';
import { authService } from '../services/authService.js';

export function renderTopUpView() {
  const urls = authService.getUrls();
  const targetUrl = urls.topup || APP_CONFIG_URLS.TOPUP_URL || 'https://noobtopup.com/';

  return `
    <div class="view-container in-app-direct-webview" style="height: 100%; width: 100%; display: flex; flex-direction: column; overflow: hidden; background: #ffffff;">
      <iframe 
        src="${targetUrl}" 
        id="topup-webview-iframe" 
        class="direct-fullscreen-iframe"
        title="NoobTopUp Store"
        sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-modals"
        loading="eager"
        style="width: 100%; height: 100%; border: none; display: block; flex: 1;">
      </iframe>
    </div>
  `;
}

export function bindTopUpEvents() {
  // Main header handles hamburger, profile, and back
}


