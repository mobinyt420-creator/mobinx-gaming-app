import { sensitivityService } from '../services/sensitivityService.js';
import { authService } from '../services/authService.js';
import { stateManager } from '../services/stateManager.js';
import { Toast } from '../components/Toast.js';

let wizardStep = 1;
let currentConfig = {
  brand: 'Samsung',
  ram: '6GB',
  dpi: '440',
  style: 'Drag Headshot (Ruok FF Style)'
};

let currentResult = null;

export function renderSensitivityView() {
  if (!currentResult) {
    currentResult = sensitivityService.calculate(currentConfig);
  }

  return `
    <div class="view-container sensitivity-view">
      <div class="subview-header">
        <div class="subview-header-left">
          <button class="back-btn" id="btn-sens-back">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="15 18 9 12 15 6"></polyline></svg>
          </button>
          <h2 class="subview-title">Sensitivity Maker</h2>
        </div>
        <span class="badge badge-primary">🎯 200 Scale Meta</span>
      </div>

      <!-- 3-Step Stepper Bar -->
      <div class="stepper-header">
        <div class="step-indicator">
          <div class="step-circle ${wizardStep >= 1 ? (wizardStep === 1 ? 'active' : 'completed') : ''}">1</div>
          <div class="step-line"></div>
          <div class="step-circle ${wizardStep >= 2 ? (wizardStep === 2 ? 'active' : 'completed') : ''}">2</div>
          <div class="step-line"></div>
          <div class="step-circle ${wizardStep === 3 ? 'active' : ''}">3</div>
        </div>
        <span style="font-size: 11px; font-weight: 700; color: var(--primary);">Step ${wizardStep} of 3</span>
      </div>

      <div class="wizard-content">
        <!-- Step 1: Device Hardware Specifications -->
        ${wizardStep === 1 ? `
          <div>
            <h3 style="font-size: 15px; font-weight: 800; margin-bottom: 4px;">Step 1: Device Hardware</h3>
            <p style="font-size: 12px; color: var(--text-secondary); margin-bottom: 12px;">Calibrates touch sampling rate and DPI curve</p>
            
            <div style="display: flex; flex-direction: column; gap: 12px;">
              <div>
                <label style="font-size: 11.5px; font-weight: 700;">Device Brand</label>
                <select id="select-brand" style="width: 100%; padding: 10px 12px; border: 1.5px solid var(--border-light); border-radius: var(--radius-md); font-size: 13px; background: #fff; margin-top: 4px;">
                  ${['Samsung Galaxy', 'Xiaomi / Poco', 'Realme', 'Infinix', 'OnePlus', 'Apple iPhone', 'Vivo / iQOO', 'Tecno', 'Other Android'].map(b => `
                    <option value="${b}" ${currentConfig.brand.startsWith(b.split(' ')[0]) ? 'selected' : ''}>${b}</option>
                  `).join('')}
                </select>
              </div>

              <div>
                <label style="font-size: 11.5px; font-weight: 700;">RAM Memory</label>
                <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px; margin-top: 4px;">
                  ${['4GB', '6GB', '8GB', '12GB+'].map(r => `
                    <button class="btn-secondary ram-select-btn ${currentConfig.ram === r ? 'active' : ''}" data-ram="${r}" style="padding: 8px 4px; font-size: 12px; ${currentConfig.ram === r ? 'border-color: var(--primary); background: var(--primary-light); color: var(--primary); font-weight: 700;' : ''}">
                      ${r}
                    </button>
                  `).join('')}
                </div>
              </div>

              <div>
                <label style="font-size: 11.5px; font-weight: 700;">Current Device DPI (Default: 420)</label>
                <input type="number" id="input-dpi" value="${currentConfig.dpi}" placeholder="420" style="width: 100%; padding: 10px 12px; border: 1.5px solid var(--border-light); border-radius: var(--radius-md); font-size: 13px; margin-top: 4px; outline: none;" />
              </div>
            </div>
          </div>
          <button class="btn-primary" id="btn-wizard-next-1" style="width: 100%; margin-top: 14px;">Continue to Playstyle →</button>
        ` : ''}

        <!-- Step 2: Pro Playstyle Selection -->
        ${wizardStep === 2 ? `
          <div>
            <h3 style="font-size: 15px; font-weight: 800; margin-bottom: 4px;">Step 2: Esports Play Style</h3>
            <p style="font-size: 12px; color: var(--text-secondary); margin-bottom: 12px;">Select pro player algorithm for vertical drag velocity</p>
            <div class="selection-grid">
              ${[
                { name: 'Drag Headshot (Ruok FF Style)', icon: '🎯', desc: 'Max vertical drag accuracy' },
                { name: 'One Tap (White444 Style)', icon: '⚡', desc: 'Fast flick & instant recoil reset' },
                { name: 'Rush & Fast Gloo Wall (Raistar Style)', icon: '🔥', desc: 'High 360° close combat speed' },
                { name: 'Balanced Competitive (Tournament Meta)', icon: '⚖️', desc: 'All-rounder tournament setup' }
              ].map(st => `
                <div class="selectable-option-card ${currentConfig.style === st.name ? 'selected' : ''}" data-step2-style="${st.name}">
                  <span class="option-icon">${st.icon}</span>
                  <span class="option-title">${st.name}</span>
                  <span style="font-size: 9px; color: var(--text-muted);">${st.desc}</span>
                </div>
              `).join('')}
            </div>
          </div>
          <div style="display: flex; gap: 10px; margin-top: 14px;">
            <button class="btn-secondary" id="btn-wizard-prev-2" style="flex: 1;">Back</button>
            <button class="btn-primary" id="btn-wizard-generate" style="flex: 2;">⚡ Generate Sensitivity</button>
          </div>
        ` : ''}

        <!-- Step 3: Results & 200 Scale Live Sliders -->
        ${wizardStep === 3 ? `
          <div class="sensitivity-results-panel">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-light); padding-bottom: 10px;">
              <div>
                <span class="badge badge-success">Free Fire OB45+ Meta</span>
                <div style="font-size: 14px; font-weight: 800; color: var(--text-main); margin-top: 2px;">
                  ${currentResult.brand} • ${currentResult.style.split(' (')[0]}
                </div>
              </div>
              <button class="btn-secondary" id="btn-recalibrate" style="padding: 6px 10px; font-size: 11px;">
                🔄 Recalibrate
              </button>
            </div>

            <!-- 200-Scale Sliders -->
            ${[
              { key: 'general', label: 'General Camera' },
              { key: 'redDot', label: 'Red Dot Sight' },
              { key: 'scope2x', label: '2X Scope' },
              { key: 'scope4x', label: '4X Scope' },
              { key: 'sniper', label: 'Sniper Scope (AWM/M82B)' },
              { key: 'freeLook', label: 'Free Look (360°)' }
            ].map(item => `
              <div class="sens-slider-row">
                <div class="sens-slider-header">
                  <span class="sens-label">${item.label}</span>
                  <span class="sens-value-badge" id="badge-sens-${item.key}">${currentResult.values[item.key]}</span>
                </div>
                <input type="range" class="custom-range-slider sens-live-slider" data-key="${item.key}" min="0" max="200" value="${currentResult.values[item.key]}" />
              </div>
            `).join('')}

            <!-- Pro Tips Box -->
            <div style="background: var(--bg-card-subtle); border-radius: var(--radius-md); padding: 10px 12px; font-size: 11px; color: var(--text-secondary); display: flex; flex-direction: column; gap: 4px;">
              <span style="font-weight: 800; color: var(--text-main);">💡 Pro Calibration Tips:</span>
              ${currentResult.proTips.map(tip => `<div>• ${tip}</div>`).join('')}
              <div style="font-weight: 700; color: var(--primary); margin-top: 2px;">• Recommended DPI: ${currentResult.dpi}</div>
            </div>

            <!-- Action Buttons -->
            <div style="display: flex; gap: 10px; margin-top: 6px;">
              <button class="btn-secondary" id="btn-save-sensitivity" style="flex: 1;">
                💾 Save Preset
              </button>
              <button class="btn-primary" id="btn-copy-sensitivity" style="flex: 1.5;">
                📋 Copy Settings
              </button>
            </div>
          </div>
        ` : ''}
      </div>
    </div>
  `;
}

export function bindSensitivityEvents() {
  document.getElementById('btn-sens-back')?.addEventListener('click', () => {
    if (wizardStep > 1) {
      wizardStep--;
      stateManager.navigate('sensitivity');
    } else {
      stateManager.navigate('home');
    }
  });

  // Step 1: Device
  document.querySelectorAll('.ram-select-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      currentConfig.ram = btn.getAttribute('data-ram');
      document.querySelectorAll('.ram-select-btn').forEach(b => {
        b.style.borderColor = 'var(--border-light)';
        b.style.background = 'var(--bg-card)';
        b.style.color = 'var(--text-main)';
      });
      btn.style.borderColor = 'var(--primary)';
      btn.style.background = 'var(--primary-light)';
      btn.style.color = 'var(--primary)';
    });
  });

  document.getElementById('btn-wizard-next-1')?.addEventListener('click', () => {
    const brand = document.getElementById('select-brand')?.value || 'Samsung';
    const dpi = document.getElementById('input-dpi')?.value || '440';
    currentConfig.brand = brand;
    currentConfig.dpi = dpi;
    wizardStep = 2;
    stateManager.navigate('sensitivity');
  });

  // Step 2: Playstyle
  document.querySelectorAll('[data-step2-style]').forEach(card => {
    card.addEventListener('click', () => {
      currentConfig.style = card.getAttribute('data-step2-style');
      document.querySelectorAll('[data-step2-style]').forEach(c => c.classList.remove('selected'));
      card.classList.add('selected');
    });
  });

  document.getElementById('btn-wizard-prev-2')?.addEventListener('click', () => {
    wizardStep = 1;
    stateManager.navigate('sensitivity');
  });

  document.getElementById('btn-wizard-generate')?.addEventListener('click', () => {
    currentResult = sensitivityService.calculate(currentConfig);
    wizardStep = 3;
    Toast.show('Sensitivity calculated successfully!', 'success');
    stateManager.navigate('sensitivity');
  });

  // Step 3: Sliders & Actions
  document.querySelectorAll('.sens-live-slider').forEach(slider => {
    slider.addEventListener('input', (e) => {
      const key = slider.getAttribute('data-key');
      const val = e.target.value;
      const badge = document.getElementById(`badge-sens-${key}`);
      if (badge) badge.textContent = val;
      if (currentResult) currentResult.values[key] = parseInt(val, 10);
    });
  });

  document.getElementById('btn-recalibrate')?.addEventListener('click', () => {
    wizardStep = 1;
    stateManager.navigate('sensitivity');
  });

  document.getElementById('btn-save-sensitivity')?.addEventListener('click', () => {
    authService.saveSensitivity({
      title: `${currentConfig.brand} Headshot Meta`,
      config: currentConfig,
      values: currentResult.values
    });
    Toast.show('Preset saved to your Profile vault!', 'success');
  });

  document.getElementById('btn-copy-sensitivity')?.addEventListener('click', () => {
    const text = `🎯 MOBIN X Sensitivity Setting (OB45+ Meta):\n• General: ${currentResult.values.general}\n• Red Dot: ${currentResult.values.redDot}\n• 2X Scope: ${currentResult.values.scope2x}\n• 4X Scope: ${currentResult.values.scope4x}\n• Sniper: ${currentResult.values.sniper}\n• Free Look: ${currentResult.values.freeLook}\n• DPI: ${currentResult.dpi}`;
    navigator.clipboard?.writeText(text);
    Toast.show('Settings copied to clipboard!', 'success');
  });
}
