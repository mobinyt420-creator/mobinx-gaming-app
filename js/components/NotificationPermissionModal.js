// ==========================================================================
// Notification Permission Modal & Smart Retry Manager
// Handles user prompt, Android 13+ runtime permissions, and smart retry logic:
// Prompts on open -> if denied, skips 2 launches and prompts again on 3rd launch!
// ==========================================================================

import { Toast } from './Toast.js';

const STORAGE_KEY_STATUS = 'mobinx_notif_permission_status'; // 'granted' | 'denied'
const STORAGE_KEY_SKIP_COUNT = 'mobinx_notif_skip_count';

export class NotificationPermissionModal {
  /**
   * Evaluates whether the notification permission prompt should be shown.
   * Call this on app startup.
   */
  static checkAndPrompt(delayMs = 1200) {
    setTimeout(() => {
      try {
        // 1. If already natively granted on Android, mark and exit
        if (typeof window !== 'undefined' && window.AndroidBridge && typeof window.AndroidBridge.isNotificationPermissionGranted === 'function') {
          if (window.AndroidBridge.isNotificationPermissionGranted()) {
            localStorage.setItem(STORAGE_KEY_STATUS, 'granted');
            return;
          }
        }

        const status = localStorage.getItem(STORAGE_KEY_STATUS);

        // If explicitly granted in localStorage, do nothing
        if (status === 'granted') {
          return;
        }

        // If previously denied, check skip counter
        if (status === 'denied') {
          const currentSkips = parseInt(localStorage.getItem(STORAGE_KEY_SKIP_COUNT) || '0', 10) + 1;
          localStorage.setItem(STORAGE_KEY_SKIP_COUNT, currentSkips.toString());

          // Rule: Skip 2 times, prompt again on the 3rd launch (when currentSkips >= 3)
          if (currentSkips < 3) {
            console.log(`[NotificationPrompt] Denied previously. Session skip count: ${currentSkips}/3`);
            return;
          }
          // On the 3rd launch, we show the prompt again!
          console.log(`[NotificationPrompt] 3rd launch reached after denial. Re-prompting user.`);
        }

        // Setup native permission result callback
        window.onNativeNotificationPermissionResult = (granted) => {
          if (granted) {
            localStorage.setItem(STORAGE_KEY_STATUS, 'granted');
            localStorage.removeItem(STORAGE_KEY_SKIP_COUNT);
            Toast.show('🔔 নোটিফিকেশন চালু হয়েছে! আপডেট সবার আগে পাবেন।', 'success');
          } else {
            localStorage.setItem(STORAGE_KEY_STATUS, 'denied');
            localStorage.setItem(STORAGE_KEY_SKIP_COUNT, '0');
          }
        };

        // 1. Android Environment: Directly request Android system permission dialog
        // This eliminates the duplicate double pop-up (custom card + OS dialog)
        if (typeof window !== 'undefined' && window.AndroidBridge && typeof window.AndroidBridge.requestNotificationPermission === 'function') {
          window.AndroidBridge.requestNotificationPermission();
          return;
        }

        // 2. Web/Desktop browser fallback only: show custom modal
        NotificationPermissionModal.show();
      } catch (e) {
        console.warn('[NotificationPrompt] Check error:', e);
      }
    }, delayMs);
  }

  /**
   * Renders and opens the notification permission dialog
   */
  static show() {
    if (document.getElementById('notif-permission-modal-root')) return;

    const modalHtml = `
      <div id="notif-permission-modal-root" class="notif-permission-backdrop" style="
        position: fixed;
        inset: 0;
        z-index: 99998;
        background: rgba(3, 7, 18, 0.82);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
        animation: notifFadeIn 0.25s ease-out;
      ">
        <div class="notif-permission-card" style="
          width: 100%;
          max-width: 380px;
          background: linear-gradient(145deg, #0f172a 0%, #0a0f1d 100%);
          border: 1.5px solid rgba(59, 130, 246, 0.35);
          border-radius: 24px;
          padding: 28px 24px 22px 24px;
          box-shadow: 0 25px 60px -10px rgba(0, 0, 0, 0.8), 0 0 40px rgba(59, 130, 246, 0.2);
          text-align: center;
          position: relative;
          animation: notifScaleUp 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        ">
          <!-- Animated Notification Bell Icon -->
          <div style="
            width: 72px;
            height: 72px;
            margin: 0 auto 18px auto;
            border-radius: 22px;
            background: radial-gradient(circle at top, #2563eb 0%, #1e3a8a 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
            box-shadow: 0 10px 25px rgba(37, 99, 235, 0.45);
            border: 1.5px solid rgba(96, 165, 250, 0.4);
            position: relative;
          ">
            <span>🔔</span>
            <span style="
              position: absolute;
              top: -3px;
              right: -3px;
              width: 14px;
              height: 14px;
              background: #ef4444;
              border-radius: 50%;
              border: 2px solid #0f172a;
              animation: notifPulse 1.8s infinite;
            "></span>
          </div>

          <h3 style="
            font-size: 20px;
            font-weight: 900;
            color: #ffffff;
            margin: 0 0 8px 0;
            letter-spacing: 0.3px;
          ">নোটিফিকেশন চালু রাখুন 📢</h3>

          <p style="
            font-size: 13px;
            line-height: 1.55;
            color: #94a3b8;
            margin: 0 0 20px 0;
          ">
            কাস্টম রুম আইডি-পাসওয়ার্ড, ফ্রি ফায়ার ডায়মন্ডের স্পেশাল অফার এবং টুর্নামেন্ট শুরুর জরুরি অ্যালার্ট সবার আগে পেতে নোটিফিকেশন অন রাখুন।
          </p>

          <div style="
            background: rgba(30, 41, 59, 0.6);
            border: 1px solid rgba(51, 65, 85, 0.6);
            border-radius: 14px;
            padding: 10px 14px;
            margin-bottom: 22px;
            display: flex;
            flex-direction: column;
            gap: 6px;
            text-align: left;
            font-size: 11.5px;
            color: #cbd5e1;
          ">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span style="color: #38bdf8;">⚡</span>
              <span>ইনস্ট্যান্ট রুম আইডি ও পাসওয়ার্ড নোটিফিকেশন</span>
            </div>
            <div style="display: flex; align-items: center; gap: 8px;">
              <span style="color: #f59e0b;">💎</span>
              <span>ফ্ল্যাশ ডিল ও ডিসকাউন্ট টপ-আপ আপডেট</span>
            </div>
            <div style="display: flex; align-items: center; gap: 8px;">
              <span style="color: #10b981;">🛡️</span>
              <span>অর্ডার স্ট্যাটাস ও ডেলিভারি কনফার্মেশন</span>
            </div>
          </div>

          <!-- Action Buttons -->
          <div style="display: flex; flex-direction: column; gap: 10px;">
            <button id="btn-notif-allow" style="
              width: 100%;
              padding: 13px;
              background: linear-gradient(135deg, #0284c7 0%, #2563eb 100%);
              color: #ffffff;
              border: none;
              border-radius: 14px;
              font-size: 14px;
              font-weight: 800;
              cursor: pointer;
              box-shadow: 0 6px 20px rgba(37, 99, 235, 0.45);
              transition: transform 0.15s ease, filter 0.15s ease;
            ">
              🔔 চালু করুন (Allow)
            </button>

            <button id="btn-notif-deny" style="
              width: 100%;
              padding: 11px;
              background: transparent;
              color: #64748b;
              border: 1px solid rgba(100, 116, 139, 0.3);
              border-radius: 14px;
              font-size: 12.5px;
              font-weight: 700;
              cursor: pointer;
              transition: all 0.15s ease;
            ">
              পরে করবো (Not Now)
            </button>
          </div>
        </div>
      </div>

      <style>
        @keyframes notifFadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes notifScaleUp {
          from { opacity: 0; transform: scale(0.92) translateY(12px); }
          to { opacity: 1; transform: scale(1) translateY(0); }
        }
        @keyframes notifPulse {
          0% { transform: scale(0.95); opacity: 0.8; }
          50% { transform: scale(1.3); opacity: 1; }
          100% { transform: scale(0.95); opacity: 0.8; }
        }
        #btn-notif-allow:hover {
          filter: brightness(1.1);
          transform: translateY(-1px);
        }
        #btn-notif-deny:hover {
          color: #94a3b8;
          border-color: rgba(148, 163, 184, 0.5);
        }
      </style>
    `;

    document.body.insertAdjacentHTML('beforeend', modalHtml);

    // Event listeners
    const modalEl = document.getElementById('notif-permission-modal-root');
    const btnAllow = document.getElementById('btn-notif-allow');
    const btnDeny = document.getElementById('btn-notif-deny');

    btnAllow?.addEventListener('click', () => {
      NotificationPermissionModal.handleAllow();
      modalEl?.remove();
    });

    btnDeny?.addEventListener('click', () => {
      NotificationPermissionModal.handleDeny();
      modalEl?.remove();
    });
  }

  static handleAllow() {
    localStorage.setItem(STORAGE_KEY_STATUS, 'granted');
    localStorage.removeItem(STORAGE_KEY_SKIP_COUNT);

    // 1. Android Native Permission Request (Android 13+)
    if (typeof window !== 'undefined' && window.AndroidBridge && typeof window.AndroidBridge.requestNotificationPermission === 'function') {
      window.AndroidBridge.requestNotificationPermission();
    } 
    // 2. Web/PWA Permission Request Fallback
    else if (typeof window !== 'undefined' && 'Notification' in window && typeof Notification.requestPermission === 'function') {
      Notification.requestPermission().catch(() => {});
    }

    Toast.show('🔔 নোটিফিকেশন চালু হয়েছে! টুর্নামেন্ট ও টপ-আপের নিয়মিত আপডেট পাবেন।', 'success');
  }

  static handleDeny() {
    localStorage.setItem(STORAGE_KEY_STATUS, 'denied');
    // Reset skip count so the user gets 2 quiet sessions before the 3rd launch prompt
    localStorage.setItem(STORAGE_KEY_SKIP_COUNT, '0');
    console.log('[NotificationPrompt] Denied by user. Will prompt again on 3rd launch.');
  }
}
