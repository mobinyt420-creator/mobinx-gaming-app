import { appUrls } from '../data/mockData.js';
import { stateManager } from '../services/stateManager.js';
import { authService } from '../services/authService.js';
import { openExternalStore } from '../services/browserService.js';

export function renderPromoBanners() {
  const shopProducts = authService.getHomeShopProducts() || [];
  const urls = authService.getUrls();

  return `
    <section class="promo-banners-section">
      <!-- Section Header -->
      <div class="section-header-row" style="margin-bottom: 10px;">
        <div class="section-title-clean">
          <span style="font-size: 15px;">🛍️</span>
          <span>Featured Shop Deals</span>
        </div>
        <div class="section-link-all" id="btn-view-all-shop-deals" role="button" tabindex="0">
          <span>Obin Shop</span>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>
      </div>

      <!-- 2 Live Shop Products Grid (Controlled via Admin Panel) -->
      <div class="home-shop-deals-grid">
        ${shopProducts.slice(0, 2).map((prod, idx) => `
          <div class="home-shop-card" data-url="${prod.url || 'https://www.obinshop.com/'}" id="home-shop-prod-${idx}">
            <div class="home-shop-img-box">
              <img src="${prod.imageUrl || 'assets/images/service_shop.jpg'}" alt="${prod.title}" class="home-shop-img" onerror="this.src='assets/images/service_shop.jpg';" />
              ${prod.tag ? `<span class="home-shop-tag-badge">${prod.tag}</span>` : ''}
            </div>
            <div class="home-shop-details">
              <span class="home-shop-cat">${prod.category || 'Shop Deal'}</span>
              <h4 class="home-shop-title" title="${prod.title}">${prod.title}</h4>
              <div class="home-shop-price-row">
                <span class="home-shop-price">${prod.price}</span>
                ${prod.originalPrice ? `<span class="home-shop-original-price">${prod.originalPrice}</span>` : ''}
              </div>
              <button class="home-shop-buy-btn" data-url="${prod.url || 'https://www.obinshop.com/'}">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3">
                  <circle cx="9" cy="21" r="1"></circle>
                  <circle cx="20" cy="21" r="1"></circle>
                  <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
                </svg>
                <span>Buy Now</span>
              </button>
            </div>
          </div>
        `).join('')}
      </div>

      <!-- Telegram Official Channel Banner -->
      <div class="promo-banner-card promo-telegram-card" id="btn-promo-telegram" style="margin-top: 12px;">
        <div class="promo-banner-texts">
          <span class="promo-tag-text">JOIN OFFICIAL</span>
          <h3 class="promo-title-text">TELEGRAM COMMUNITY</h3>
          <p class="promo-sub-text">Get Instant Diamond Top-Up & Tournament Alerts First</p>
        </div>
        <div class="promo-icon-badge telegram-badge">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="#ffffff">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm4.64 6.8c-.15 1.58-.8 5.42-1.13 7.19-.14.75-.42 1-.68 1.03-.58.05-1.02-.38-1.58-.75-.88-.58-1.38-.94-2.23-1.5-.99-.65-.35-1.01.22-1.59.15-.15 2.71-2.48 2.76-2.69.01-.03.01-.14-.05-.2-.06-.06-.15-.04-.22-.02-.1.02-1.63 1.04-4.61 3.05-.44.3-.83.45-1.19.44-.39-.01-1.15-.22-1.71-.4-.69-.22-1.24-.34-1.19-.72.03-.2.3-.4.82-.62 3.23-1.41 5.39-2.34 6.49-2.8 3.09-1.3 3.73-1.53 4.15-1.53.09 0 .3.02.43.13.11.09.14.22.16.31-.01.07.01.22 0 .34z"/>
          </svg>
        </div>
      </div>

      <!-- YouTube Official Channel Banner -->
      <div class="promo-banner-card promo-youtube-card" id="btn-promo-youtube" style="margin-top: 10px;">
        <div class="promo-banner-texts">
          <span class="promo-tag-text" style="color: #fca5a5;">SUBSCRIBE OFFICIAL</span>
          <h3 class="promo-title-text">YOUTUBE CHANNEL</h3>
          <p class="promo-sub-text">Watch Free Fire Tournaments, Highlights & Guides</p>
        </div>
        <div class="promo-icon-badge" style="background: linear-gradient(135deg, #ef4444 0%, #b91c1c 100%);">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="#ffffff">
            <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
          </svg>
        </div>
      </div>
    </section>
  `;
}

export function bindPromoBannersEvents() {
  // Bind dynamic shop cards
  document.querySelectorAll('.home-shop-card').forEach(card => {
    card.addEventListener('click', (e) => {
      // Don't trigger twice if buy button was clicked
      if (e.target.closest('.home-shop-buy-btn')) return;
      const targetUrl = card.getAttribute('data-url') || 'https://www.obinshop.com/';
      openExternalStore(targetUrl, '#7c3aed');
    });
  });

  // Bind Buy Now button explicitly
  document.querySelectorAll('.home-shop-buy-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const targetUrl = btn.getAttribute('data-url') || 'https://www.obinshop.com/';
      openExternalStore(targetUrl, '#7c3aed');
    });
  });

  // View All shop link
  document.getElementById('btn-view-all-shop-deals')?.addEventListener('click', () => {
    const urls = authService.getUrls();
    openExternalStore(urls.shop || 'https://www.obinshop.com/', '#7c3aed');
  });

  // Telegram banner click
  document.getElementById('btn-promo-telegram')?.addEventListener('click', () => {
    const urls = authService.getUrls();
    window.open(urls.telegram || appUrls.telegram, '_blank');
  });

  // YouTube banner click
  document.getElementById('btn-promo-youtube')?.addEventListener('click', () => {
    const urls = authService.getUrls();
    window.open(urls.youtube || appUrls.youtube, '_blank');
  });
}
