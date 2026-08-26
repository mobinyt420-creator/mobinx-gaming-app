import { APP_CONFIG_URLS } from '../config/urls.js';
import { stateManager } from '../services/stateManager.js';
import { authService } from '../services/authService.js';

export function renderTopUpView() {
  const urls = authService.getUrls();
  const targetUrl = urls.topup || APP_CONFIG_URLS.TOPUP_URL || 'https://noobtopup.com/';

  return `
    <div class="view-container in-app-direct-webview" style="height: 100%; width: 100%; display: flex; flex-direction: column; overflow: hidden; background: #0f172a;">
      <!-- Webview Control Bar (Allows returning to app & external browser fallback) -->
      <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 14px; background: #0b1329; border-bottom: 1px solid rgba(255,255,255,0.1); flex-shrink: 0; z-index: 30;">
        <button id="btn-webview-back-home" style="display: flex; align-items: center; gap: 6px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); color: #ffffff; padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 700; cursor: pointer;">
          <span>◀</span>
          <span>Back to App</span>
        </button>

        <div style="display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 800; color: #38bdf8;">
          <span>💎</span>
          <span>NoobTopUp Store</span>
        </div>

        <div style="display: flex; gap: 6px; align-items: center;">
          <button id="btn-webview-reload" title="Refresh Page" style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); color: #ffffff; width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; cursor: pointer; font-size: 13px;">
            🔄
          </button>
          <a href="${targetUrl}" target="_blank" rel="noopener noreferrer" title="Open in External Browser" style="background: rgba(37,99,235,0.25); border: 1px solid #2563eb; color: #60a5fa; width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; text-decoration: none; font-size: 13px;">
            🌐
          </a>
        </div>
      </div>

      <!-- Seamless In-App Iframe (No Sandbox restrictions to allow full login and payment) -->
      <iframe 
        src="${targetUrl}" 
        id="topup-webview-iframe" 
        class="direct-fullscreen-iframe"
        title="NoobTopUp Store"
        allow="payment; camera; microphone; geolocation; clipboard-read; clipboard-write; autoplay; fullscreen"
        loading="eager"
        style="width: 100%; height: 100%; border: none; display: block; flex: 1; background: #ffffff;">
      </iframe>
    </div>
  `;
}

export function bindTopUpEvents() {
  document.getElementById('btn-webview-back-home')?.addEventListener('click', () => {
    stateManager.navigate('home');
  });

  document.getElementById('btn-webview-reload')?.addEventListener('click', () => {
    const iframe = document.getElementById('topup-webview-iframe');
    if (iframe) {
      const currentSrc = iframe.src;
      iframe.src = '';
      setTimeout(() => { iframe.src = currentSrc; }, 50);
    }
  });
}
