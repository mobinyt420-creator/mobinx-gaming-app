import { authService } from '../services/authService.js';
import { stateManager } from '../services/stateManager.js';
import { openExternalStore } from '../services/browserService.js';

export function renderPopularServicesGrid() {
  const services = authService.getPopularServices();

  return `
    <section class="popular-services-section">
      <div class="section-header-row">
        <div class="section-title-clean">
          <span style="font-size: 16px;">👑</span>
          <span>Popular Services</span>
        </div>
        <div class="section-link-all" id="btn-view-all-services" role="button" tabindex="0">
          <span>View All</span>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>
      </div>

      <div class="popular-grid-3col">
        ${services.map(service => `
          <div class="popular-service-card" data-service="${service.route}" id="service-card-${service.id}">
            <div class="service-image-box">
              <img src="${service.image}" alt="${service.title}" class="service-card-img" />
            </div>
            <div class="service-label-container">
              <span class="service-title-uppercase">${service.title}</span>
            </div>
          </div>
        `).join('')}
      </div>
    </section>
  `;
}

export function bindPopularServicesEvents() {
  document.querySelectorAll('.popular-service-card').forEach(card => {
    card.addEventListener('click', () => {
      const route = card.getAttribute('data-service');
      if (route === 'topup') {
        const urls = authService.getUrls();
        openExternalStore(urls.topup || 'https://noobtopup.com/', '#0284c7');
        return;
      }
      if (route === 'shop') {
        const urls = authService.getUrls();
        openExternalStore(urls.shop || 'https://www.obinshop.com/', '#7c3aed');
        return;
      }
      if (route) {
        stateManager.navigate(route);
      }
    });
  });

  document.getElementById('btn-view-all-services')?.addEventListener('click', () => {
    stateManager.toggleDrawer(true);
  });
}

