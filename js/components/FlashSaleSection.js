import { authService } from '../services/authService.js';
import { stateManager } from '../services/stateManager.js';
import { Toast } from './Toast.js';
import { openExternalStore } from '../services/browserService.js';

let countdownTimer = null;
let remainingSeconds = 2 * 3600 + 35 * 60 + 19; // 02:35:19 matching screenshot
let flashGlideRaf = null;
let flashIsInteracting = false;
let flashResumeTimeout = null;

export function renderFlashSaleSection() {
  const authSettings = authService.getAuthSettings();
  if (authSettings.topUpEnabled === false) return '';

  const storedProducts = authService.getFlashDeals();
  const rawProducts = (storedProducts && storedProducts.length > 0) ? storedProducts : [
    { id: "flash-1", diamondAmount: "2000 DIAMONDS", price: "৳ 1,480.00", badge: "VIP", badgeColor: "#2563eb", isActive: true },
    { id: "flash-2", diamondAmount: "100 DIAMONDS", price: "৳ 80.00", badge: "HOT", badgeColor: "#ea580c", isActive: true },
    { id: "flash-3", diamondAmount: "100 DIAMONDS", price: "৳ 80.00", badge: "100% BONUS", badgeColor: "#0284c7", isActive: true },
    { id: "flash-4", diamondAmount: "520 DIAMONDS", price: "৳ 420.00", badge: "BEST VALUE", badgeColor: "#16a34a", isActive: true },
    { id: "flash-5", diamondAmount: "1060 DIAMONDS", price: "৳ 820.00", badge: "VIP BONUS", badgeColor: "#9333ea", isActive: true }
  ];

  const baseProducts = rawProducts.filter(p => p.isActive !== false && p.status !== 'inactive');
  if (baseProducts.length === 0) return '';

  // Repeat for continuous seamless infinite glide
  const duplicatedProducts = [...baseProducts, ...baseProducts, ...baseProducts, ...baseProducts];

  return `
    <section class="flash-diamond-section">
      <!-- Dark Gaming Header Banner -->
      <div class="flash-header-banner">
        <div class="flash-header-left">
          <div class="flash-bolt-box">
            <svg class="flash-bolt-icon" width="18" height="18" viewBox="0 0 24 24" fill="#facc15">
              <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon>
            </svg>
          </div>
          <span class="flash-header-title">FLASH</span>
          <span class="flash-header-title-light">DIAMOND TOP UP</span>
        </div>

        <div class="flash-countdown-pill">
          <span class="flash-fire-icon">🔥</span>
          <span class="flash-timer-digits" id="flash-countdown-digits">02 : 35 : 19</span>
        </div>
      </div>

      <!-- Horizontal Seamless Infinite Auto-Scrolling Diamond Carousel with Touch Support -->
      <div class="flash-products-carousel" id="flash-products-track-container">
        <div class="flash-products-track" id="flash-products-track">
          ${duplicatedProducts.map((prod, idx) => `
            <div class="flash-diamond-card" data-product-id="${prod.id}" id="flash-card-${prod.id}-${idx}">
              <div class="flash-card-badge" style="background: ${prod.badgeColor || (idx % 2 === 0 ? '#ea580c' : '#2563eb')}; color: #ffffff;">
                ${prod.badge || 'FLASH DEAL'}
              </div>

              <!-- Ultra-Realistic 3D Faceted Sparkling Diamond Gem Graphic -->
              <div class="flash-card-diamond-graphic diamond-glow-effect">
                <span class="diamond-sparkle-star s1">✦</span>
                <span class="diamond-sparkle-star s2">✨</span>
                <svg class="sparkling-diamond-svg" width="48" height="48" viewBox="0 0 48 48" fill="none">
                  <defs>
                    <linearGradient id="diamTableGrad-${prod.id}-${idx}" x1="12" y1="8" x2="36" y2="18" gradientUnits="userSpaceOnUse">
                      <stop stop-color="#bae6fd"/>
                      <stop offset="1" stop-color="#7dd3fc"/>
                    </linearGradient>
                    <linearGradient id="diamLeftGrad-${prod.id}-${idx}" x1="4" y1="18" x2="24" y2="44" gradientUnits="userSpaceOnUse">
                      <stop stop-color="#38bdf8"/>
                      <stop offset="1" stop-color="#0284c7"/>
                    </linearGradient>
                    <linearGradient id="diamCenterGrad-${prod.id}-${idx}" x1="16" y1="18" x2="32" y2="44" gradientUnits="userSpaceOnUse">
                      <stop stop-color="#e0f2fe"/>
                      <stop offset="0.35" stop-color="#38bdf8"/>
                      <stop offset="1" stop-color="#0369a1"/>
                    </linearGradient>
                    <linearGradient id="diamRightGrad-${prod.id}-${idx}" x1="28" y1="18" x2="44" y2="44" gradientUnits="userSpaceOnUse">
                      <stop stop-color="#0284c7"/>
                      <stop offset="1" stop-color="#0c4a6e"/>
                    </linearGradient>
                  </defs>

                  <!-- 3D Diamond Crown Facets -->
                  <polygon points="14,8 34,8 28,18 20,18" fill="url(#diamTableGrad-${prod.id}-${idx})"/>
                  <polygon points="6,18 14,8 20,18" fill="#38bdf8" opacity="0.9"/>
                  <polygon points="42,18 34,8 28,18" fill="#0284c7"/>

                  <!-- 3D Diamond Pavilion Facets -->
                  <polygon points="6,18 20,18 24,42" fill="url(#diamLeftGrad-${prod.id}-${idx})"/>
                  <polygon points="20,18 28,18 24,42" fill="url(#diamCenterGrad-${prod.id}-${idx})"/>
                  <polygon points="28,18 42,18 24,42" fill="url(#diamRightGrad-${prod.id}-${idx})"/>

                  <!-- Specular Shimmer Lines -->
                  <polyline points="14,8 34,8" stroke="#ffffff" stroke-width="1.8" stroke-linecap="round" opacity="0.95"/>
                  <line x1="6" y1="18" x2="42" y2="18" stroke="#ffffff" stroke-width="1.1" opacity="0.75"/>
                  <line x1="20" y1="18" x2="24" y2="42" stroke="#ffffff" stroke-width="0.9" opacity="0.6"/>
                  <line x1="28" y1="18" x2="24" y2="42" stroke="#ffffff" stroke-width="0.9" opacity="0.6"/>
                </svg>
              </div>

              <div class="flash-card-details">
                <div class="flash-diamond-qty">${prod.diamondAmount}</div>
                <div class="flash-diamond-price">${prod.price}</div>
              </div>

              <button class="flash-buy-btn btn-gold" data-buy-id="${prod.id}" data-amount="${prod.diamondAmount}" data-price="${prod.price}">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3">
                  <circle cx="9" cy="21" r="1"></circle>
                  <circle cx="20" cy="21" r="1"></circle>
                  <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
                </svg>
                <span>Buy Now</span>
              </button>
            </div>
          `).join('')}
        </div>
      </div>
    </section>
  `;
}

export function initFlashSaleCountdown() {
  const digitsEl = document.getElementById('flash-countdown-digits');

  if (countdownTimer) clearInterval(countdownTimer);

  function formatTime(totalSec) {
    const hrs = String(Math.floor(totalSec / 3600)).padStart(2, '0');
    const mins = String(Math.floor((totalSec % 3600) / 60)).padStart(2, '0');
    const secs = String(totalSec % 60).padStart(2, '0');
    return `${hrs} : ${mins} : ${secs}`;
  }

  countdownTimer = setInterval(() => {
    if (remainingSeconds > 0) {
      remainingSeconds--;
      if (digitsEl) digitsEl.textContent = formatTime(remainingSeconds);
    }
  }, 1000);

  // Smooth Auto-Glide + Touch Drag for Flash Deals Track
  const container = document.getElementById('flash-products-track-container');
  if (container) {
    if (flashGlideRaf) cancelAnimationFrame(flashGlideRaf);
    if (flashResumeTimeout) clearTimeout(flashResumeTimeout);

    const speed = 0.55;

    function tick() {
      if (!flashIsInteracting && container) {
        container.scrollLeft += speed;
        const halfWidth = (container.scrollWidth - container.clientWidth) / 2;
        if (halfWidth > 0 && container.scrollLeft >= halfWidth) {
          container.scrollLeft -= halfWidth;
        }
      }
      flashGlideRaf = requestAnimationFrame(tick);
    }

    let isDown = false;
    let startX = 0;
    let scrollLeftStart = 0;

    container.addEventListener('pointerdown', (e) => {
      isDown = true;
      flashIsInteracting = true;
      startX = e.pageX || (e.touches && e.touches[0].pageX);
      scrollLeftStart = container.scrollLeft;
      if (flashResumeTimeout) clearTimeout(flashResumeTimeout);
    });

    const onMove = (e) => {
      if (!isDown) return;
      const currentX = e.pageX || (e.touches && e.touches[0].pageX);
      const walk = (currentX - startX) * 1.2;
      container.scrollLeft = scrollLeftStart - walk;
    };

    const onUp = () => {
      if (!isDown) return;
      isDown = false;
      if (flashResumeTimeout) clearTimeout(flashResumeTimeout);
      flashResumeTimeout = setTimeout(() => {
        flashIsInteracting = false;
      }, 1200);
    };

    container.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
    window.addEventListener('pointercancel', onUp);

    container.addEventListener('touchstart', () => {
      flashIsInteracting = true;
      if (flashResumeTimeout) clearTimeout(flashResumeTimeout);
    }, { passive: true });

    container.addEventListener('touchend', () => {
      if (flashResumeTimeout) clearTimeout(flashResumeTimeout);
      flashResumeTimeout = setTimeout(() => {
        flashIsInteracting = false;
      }, 1400);
    }, { passive: true });

    flashGlideRaf = requestAnimationFrame(tick);
  }

  // Buy Now click interactions
  document.querySelectorAll('.flash-buy-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const amount = btn.dataset.amount || 'Diamonds';
      const price = btn.dataset.price || '';
      Toast.show(`Opening Top Up for ${amount} (${price})...`, 'info');
      const urls = authService.getUrls();
      openExternalStore(urls.topup || 'https://noobtopup.com/', '#004b87');
    });
  });
}
