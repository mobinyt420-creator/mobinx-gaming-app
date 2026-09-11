import { quickCategories } from '../data/mockData.js';
import { stateManager } from '../services/stateManager.js';
import { authService } from '../services/authService.js';
import { openExternalStore } from '../services/browserService.js';

let glideRaf = null;
let isInteracting = false;
let resumeTimeout = null;

export function renderCategorySlider() {
  const iconSvgs = {
    diamond: `
      <svg class="category-icon-svg animated-gem-icon" width="26" height="26" viewBox="0 0 24 24" fill="none">
        <path d="M6 3H18L22 9L12 22L2 9L6 3Z" fill="url(#catDiamondGrad)" stroke="#38bdf8" stroke-width="1.4" stroke-linejoin="round"/>
        <path d="M2 9H22M12 22L7 9M12 22L17 9M6 3L8.5 9M18 3L15.5 9" stroke="#ffffff" stroke-width="1.1" stroke-linejoin="round" opacity="0.85"/>
        <defs>
          <linearGradient id="catDiamondGrad" x1="2" y1="3" x2="22" y2="22" gradientUnits="userSpaceOnUse">
            <stop stop-color="#38bdf8"/>
            <stop offset="0.5" stop-color="#0284c7"/>
            <stop offset="1" stop-color="#1e40af"/>
          </linearGradient>
        </defs>
      </svg>`,
    bag: `
      <svg class="category-icon-svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path d="M6 8V6C6 3.79086 7.79086 2 10 2H14C16.2091 2 18 3.79086 18 6V8" stroke="#7c3aed" stroke-width="2" stroke-linecap="round"/>
        <rect x="3" y="8" width="18" height="14" rx="4" fill="url(#catBagGrad)" stroke="#6d28d9" stroke-width="1.5"/>
        <path d="M9 12C9 13.6569 10.3431 15 12 15C13.6569 15 15 13.6569 15 12" stroke="#ffffff" stroke-width="2" stroke-linecap="round"/>
        <defs>
          <linearGradient id="catBagGrad" x1="3" y1="8" x2="21" y2="22" gradientUnits="userSpaceOnUse">
            <stop stop-color="#a855f7"/>
            <stop offset="1" stop-color="#6d28d9"/>
          </linearGradient>
        </defs>
      </svg>`,
    sliders: `
      <svg class="category-icon-svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#0284c7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <line x1="4" y1="21" x2="4" y2="14"></line>
        <line x1="4" y1="10" x2="4" y2="3"></line>
        <line x1="12" y1="21" x2="12" y2="12"></line>
        <line x1="12" y1="8" x2="12" y2="3"></line>
        <line x1="20" y1="21" x2="20" y2="16"></line>
        <line x1="20" y1="12" x2="20" y2="3"></line>
        <line x1="1" y1="14" x2="7" y2="14"></line>
        <line x1="9" y1="8" x2="15" y2="8"></line>
        <line x1="17" y1="16" x2="23" y2="16"></line>
      </svg>`,
    gift: `
      <svg class="category-icon-svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
        <rect x="3" y="8" width="18" height="13" rx="3" fill="url(#catGiftGrad)" stroke="#db2777" stroke-width="1.5"/>
        <path d="M2 5H22V8H2V5Z" fill="#f472b6" stroke="#db2777" stroke-width="1.2"/>
        <line x1="12" y1="5" x2="12" y2="21" stroke="#ffffff" stroke-width="2.2" stroke-linecap="round"/>
        <path d="M12 5C12 5 9.5 2 7.5 2C5.5 2 5.5 5 12 5Z" fill="#ec4899"/>
        <path d="M12 5C12 5 14.5 2 16.5 2C18.5 2 18.5 5 12 5Z" fill="#ec4899"/>
        <defs>
          <linearGradient id="catGiftGrad" x1="3" y1="8" x2="21" y2="21" gradientUnits="userSpaceOnUse">
            <stop stop-color="#f472b6"/>
            <stop offset="1" stop-color="#db2777"/>
          </linearGradient>
        </defs>
      </svg>`,
    telegram: `
      <svg class="category-icon-svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
        <circle cx="12" cy="12" r="10" fill="url(#catTgGrad)"/>
        <path d="M17.5 7L5.5 11.5L10 13.5L14.5 9.5L11 14.5L15.5 17L17.5 7Z" fill="#ffffff" stroke="#ffffff" stroke-width="0.8" stroke-linejoin="round"/>
        <defs>
          <linearGradient id="catTgGrad" x1="2" y1="2" x2="22" y2="22" gradientUnits="userSpaceOnUse">
            <stop stop-color="#38bdf8"/>
            <stop offset="1" stop-color="#0284c7"/>
          </linearGradient>
        </defs>
      </svg>`,
    'cloud-download': `
      <svg class="category-icon-svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
        <circle cx="12" cy="12" r="10" fill="url(#catDlGrad)"/>
        <path d="M12 7V15M12 15L9 12M12 15L15 12" stroke="#ffffff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
        <path d="M8 17H16" stroke="#ffffff" stroke-width="2.2" stroke-linecap="round"/>
        <defs>
          <linearGradient id="catDlGrad" x1="2" y1="2" x2="22" y2="22" gradientUnits="userSpaceOnUse">
            <stop stop-color="#34d399"/>
            <stop offset="1" stop-color="#059669"/>
          </linearGradient>
        </defs>
      </svg>`,
    trophy: `
      <svg class="category-icon-svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path d="M6 4H18V10C18 13.3137 15.3137 16 12 16C8.68629 16 6 13.3137 6 10V4Z" fill="url(#catTrophyGrad)" stroke="#d97706" stroke-width="1.5"/>
        <path d="M6 6H3C2.44772 6 2 6.44772 2 7V8C2 9.65685 3.34315 11 5 11H6" stroke="#d97706" stroke-width="1.8"/>
        <path d="M18 6H21C21.5523 6 22 6.44772 22 7V8C22 9.65685 20.6569 11 19 11H18" stroke="#d97706" stroke-width="1.8"/>
        <path d="M12 16V19M8 22H16" stroke="#d97706" stroke-width="2" stroke-linecap="round"/>
        <defs>
          <linearGradient id="catTrophyGrad" x1="6" y1="4" x2="18" y2="16" gradientUnits="userSpaceOnUse">
            <stop stop-color="#fbbf24"/>
            <stop offset="1" stop-color="#d97706"/>
          </linearGradient>
        </defs>
      </svg>`
  };

  const authSettings = authService.getAuthSettings();
  const activeCategories = quickCategories.filter(cat => {
    if (cat.route === 'topup' && authSettings.topUpEnabled === false) return false;
    return true;
  });

  // Duplicate set to create seamless infinite loop animation
  const duplicatedList = [...activeCategories, ...activeCategories, ...activeCategories];

  return `
    <section class="category-section">
      <div class="category-marquee-container" id="category-track-container">
        <div class="category-marquee-track" id="category-scroll-track">
          ${duplicatedList.map((cat, idx) => `
            <div class="category-shortcut-card" data-category="${cat.route}" id="cat-btn-${cat.id}-${idx}">
              <div class="category-icon-box" style="background: ${cat.bgGradient};">
                ${iconSvgs[cat.icon] || iconSvgs.diamond}
              </div>
              <span class="category-shortcut-label">${cat.title}</span>
            </div>
          `).join('')}
        </div>
      </div>
    </section>
  `;
}

export function bindCategoryEvents() {
  const container = document.getElementById('category-track-container');
  
  if (container) {
    if (glideRaf) cancelAnimationFrame(glideRaf);
    if (resumeTimeout) clearTimeout(resumeTimeout);

    const speed = 0.55; // Silky smooth speed

    function tick() {
      if (!isInteracting && container) {
        container.scrollLeft += speed;
        const halfWidth = (container.scrollWidth - container.clientWidth) / 2;
        if (halfWidth > 0 && container.scrollLeft >= halfWidth) {
          container.scrollLeft -= halfWidth;
        }
      }
      glideRaf = requestAnimationFrame(tick);
    }

    // Touch and pointer dragging support
    let isDown = false;
    let startX = 0;
    let scrollLeftStart = 0;
    let dragThreshold = 0;

    container.addEventListener('pointerdown', (e) => {
      isDown = true;
      isInteracting = true;
      dragThreshold = 0;
      startX = e.pageX || (e.touches && e.touches[0].pageX);
      scrollLeftStart = container.scrollLeft;
      if (resumeTimeout) clearTimeout(resumeTimeout);
    });

    const onMove = (e) => {
      if (!isDown) return;
      const currentX = e.pageX || (e.touches && e.touches[0].pageX);
      const walk = (currentX - startX) * 1.2;
      dragThreshold += Math.abs(walk);
      container.scrollLeft = scrollLeftStart - walk;
    };

    const onUp = () => {
      if (!isDown) return;
      isDown = false;
      if (resumeTimeout) clearTimeout(resumeTimeout);
      resumeTimeout = setTimeout(() => {
        isInteracting = false;
      }, 1200);
    };

    container.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
    window.addEventListener('pointercancel', onUp);

    container.addEventListener('touchstart', () => {
      isInteracting = true;
      if (resumeTimeout) clearTimeout(resumeTimeout);
    }, { passive: true });

    container.addEventListener('touchend', () => {
      if (resumeTimeout) clearTimeout(resumeTimeout);
      resumeTimeout = setTimeout(() => {
        isInteracting = false;
      }, 1400);
    }, { passive: true });

    glideRaf = requestAnimationFrame(tick);
  }

  // Bind shortcut card navigation
  document.querySelectorAll('.category-shortcut-card').forEach(card => {
    card.addEventListener('click', (e) => {
      const route = card.getAttribute('data-category');
      if (route === 'topup') {
        const urls = authService.getUrls();
        openExternalStore(urls.topup || 'https://noobtopup.com/', '#004b87');
        return;
      }
      if (route === 'shop') {
        const urls = authService.getUrls();
        openExternalStore(urls.shop || 'https://www.obinshop.com/', '#7c3aed');
        return;
      }
      if (route === 'community') {
        const urls = authService.getUrls();
        window.open(urls.telegram || 'https://t.me/mrmobin1m', '_blank');
        return;
      }
      if (route) {
        stateManager.navigate(route);
      }
    });
  });
}
