import { stateManager } from '../services/stateManager.js';

export function renderAboutView() {
  return `
    <div class="view-container about-view">
      <div class="subview-header">
        <div class="subview-header-left">
          <button class="back-btn" id="btn-about-back">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="15 18 9 12 15 6"></polyline></svg>
          </button>
          <h2 class="subview-title">About OBIN</h2>
        </div>
      </div>

      <div style="padding: 24px 16px; display: flex; flex-direction: column; align-items: center; text-align: center; gap: 16px;">
        <div style="width: 72px; height: 72px; border-radius: 20px; overflow: hidden; box-shadow: 0 8px 24px rgba(2, 132, 199, 0.25); border: 1.5px solid rgba(56, 189, 248, 0.3);">
          <img src="assets/images/obin_icon_512.png" alt="OBIN" style="width: 100%; height: 100%; object-fit: cover;" />
        </div>

        <div>
          <h2 style="font-size: 20px; font-weight: 900; color: var(--text-main); letter-spacing: 0.5px;">OBIN</h2>
          <span style="font-size: 12px; color: var(--primary); font-weight: 700;">The Ultimate Super App • V1.0.0</span>
        </div>

        <p style="font-size: 13px; color: var(--text-secondary); line-height: 1.5; max-width: 320px;">
          OBIN is a next-generation super app combining shop & e-commerce, instant diamond top-ups, custom sensitivity calibrations, safe resource downloads, and esports tournaments.
        </p>

        <div style="width: 100%; background: #ffffff; border: 1px solid var(--border-light); border-radius: var(--radius-xl); padding: 14px; display: flex; flex-direction: column; gap: 8px; text-align: left; font-size: 12px;">
          <div style="display: flex; justify-content: space-between;">
            <span style="color: var(--text-muted);">Version</span>
            <span style="font-weight: 700;">1.0.0 Stable (Build 2026.09)</span>
          </div>
          <div style="display: flex; justify-content: space-between;">
            <span style="color: var(--text-muted);">Platform</span>
            <span style="font-weight: 700;">OBIN Super App Ecosystem</span>
          </div>
          <div style="display: flex; justify-content: space-between;">
            <span style="color: var(--text-muted);">Security Engine</span>
            <span style="font-weight: 700; color: var(--success);">OBIN Shield 2.0 (Active)</span>
          </div>
        </div>

        <button class="btn-primary" id="btn-about-home-cta" style="width: 100%; margin-top: 10px;">
          Back to Home
        </button>
      </div>
    </div>
  `;
}

export function bindAboutEvents() {
  document.getElementById('btn-about-back')?.addEventListener('click', () => {
    stateManager.navigate('home');
  });

  document.getElementById('btn-about-home-cta')?.addEventListener('click', () => {
    stateManager.navigate('home');
  });
}
