import { defaultUser, appUrls } from '../data/mockData.js';
import { firebaseService } from './firebaseService.js';

// Master Admin Email
export const MASTER_ADMIN_EMAIL = "mobinyt420@gmail.com";

// Real registered users list (Zero fake dummy users for Play Store production)
const initialRegisteredUsers = [];

class AuthService {
  constructor() {
    const hasStorage = typeof localStorage !== 'undefined';
    const savedSession = hasStorage ? localStorage.getItem('mobinx_user_session') : null;
    const adminEmail = hasStorage ? localStorage.getItem('mobinx_admin_email') : null;
    const customUrls = hasStorage ? localStorage.getItem('mobinx_custom_urls') : null;
    const savedUsers = hasStorage ? localStorage.getItem('mobinx_registered_users') : null;

    // Load registered users (clean, zero fake dummy users)
    this.registeredUsers = savedUsers ? JSON.parse(savedUsers) : [];

    this.user = savedSession ? JSON.parse(savedSession) : { ...defaultUser };
    this.adminEmail = adminEmail || MASTER_ADMIN_EMAIL;
    this.urls = customUrls ? JSON.parse(customUrls) : { ...appUrls };
    this.savedSensitivities = (hasStorage && JSON.parse(localStorage.getItem('mobinx_saved_sens') || '[]')) || [];

    // Check admin status
    if (this.user && this.user.email) {
      const email = this.user.email.toLowerCase();
      if (email === MASTER_ADMIN_EMAIL.toLowerCase() || email === 'mrmobin1m@gmail.com' || email === this.adminEmail.toLowerCase()) {
        this.user.isAdmin = true;
        this.user.role = "System Administrator (Admin)";
      }
    }
  }

  persistSession() {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_user_session', JSON.stringify(this.user));
    }
  }

  async loginWithGoogle(email, username, phone = '', ffUid = '') {
    const cleanEmail = (email || '').toLowerCase().trim();
    const cleanUsername = (username || cleanEmail.split('@')[0] || 'Player').trim();
    
    // Check if user already exists
    let existing = this.registeredUsers.find(u => u.email && u.email.toLowerCase() === cleanEmail);
    if (!existing) {
      const newPlayerNum = this.registeredUsers.length + 1;
      existing = {
        id: String(newPlayerNum),
        userId: newPlayerNum,
        playerNumber: newPlayerNum,
        username: cleanUsername,
        fullName: cleanUsername,
        email: cleanEmail,
        phone: phone || '',
        ffUid: ffUid || '',
        avatar: `https://api.dicebear.com/7.x/bottts/svg?seed=${encodeURIComponent(cleanUsername)}`,
        role: "Player",
        isAdmin: cleanEmail === MASTER_ADMIN_EMAIL.toLowerCase(),
        status: "Active",
        registeredDate: new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' }),
        registeredAtIso: new Date().toISOString(),
        platform: typeof navigator !== 'undefined' && navigator.userAgent && navigator.userAgent.includes('Android') ? 'Android Mobile' : 'Web Device',
        ip: 'Connected'
      };
      this.registeredUsers.push(existing);
      this.saveUsersDatabase();
    } else {
      if (phone) existing.phone = phone;
      if (ffUid) existing.ffUid = ffUid;
      this.saveUsersDatabase();
    }

    this.user = { ...existing };
    this.persistSession();

    // Sync to Cloud Firestore
    try {
      await firebaseService.saveToFirestore('users', existing.id, existing);
    } catch(e) {}

    return this.user;
  }

  hasCompletedOnboarding() {
    if (typeof localStorage === 'undefined') return true;
    return !!localStorage.getItem('mobinx_onboarded');
  }

  setOnboardingCompleted(completed = true) {
    if (typeof localStorage !== 'undefined') {
      if (completed) {
        localStorage.setItem('mobinx_onboarded', 'true');
      } else {
        localStorage.removeItem('mobinx_onboarded');
      }
    }
  }

  getCurrentUser() {
    return this.user;
  }

  isAdmin() {
    return !!(this.user && (this.user.isAdmin || this.user.email.toLowerCase() === this.adminEmail.toLowerCase()));
  }

  getUrls() {
    return this.urls;
  }

  updateUrls(newUrls) {
    this.urls = { ...this.urls, ...newUrls };
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_custom_urls', JSON.stringify(this.urls));
    }
    return this.urls;
  }

  // --- USER MANAGEMENT (Admin Features) ---
  getAllUsers() {
    return this.registeredUsers;
  }

  getUserById(userId) {
    return this.registeredUsers.find(u => u.id === userId);
  }

  updateUserRole(userId, newRole, makeAdmin = false) {
    const userObj = this.registeredUsers.find(u => u.id === userId);
    if (userObj) {
      userObj.role = newRole;
      userObj.isAdmin = makeAdmin;
      this.saveUsersDatabase();
      
      // If current user is modified, sync session
      if (this.user && this.user.id === userId) {
        this.user.role = newRole;
        this.user.isAdmin = makeAdmin;
        this.persistSession();
      }
    }
    return userObj;
  }

  updateUserBalance(userId, deltaTk, deltaDiamonds = 0) {
    const userObj = this.registeredUsers.find(u => u.id === userId);
    if (userObj) {
      userObj.walletBalance = Math.max(0, (userObj.walletBalance || 0) + deltaTk);
      userObj.diamonds = Math.max(0, (userObj.diamonds || 0) + deltaDiamonds);
      this.saveUsersDatabase();

      if (this.user && this.user.id === userId) {
        this.user.walletBalance = userObj.walletBalance;
        this.user.diamonds = userObj.diamonds;
        this.persistSession();
      }
    }
    return userObj;
  }

  toggleUserStatus(userId) {
    const userObj = this.registeredUsers.find(u => u.id === userId);
    if (userObj) {
      userObj.status = userObj.status === 'Active' ? 'Suspended' : 'Active';
      this.saveUsersDatabase();
    }
    return userObj;
  }

  deleteUser(userId) {
    const index = this.registeredUsers.findIndex(u => u.id === userId);
    if (index !== -1) {
      const removed = this.registeredUsers.splice(index, 1)[0];
      this.saveUsersDatabase();
      return removed;
    }
    return null;
  }

  saveUsersDatabase() {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_registered_users', JSON.stringify(this.registeredUsers));
    }
  }

  // --- FLASH DEALS MANAGEMENT ---
  getFlashDeals() {
    if (typeof localStorage !== 'undefined') {
      const stored = localStorage.getItem('mobinx_flash_deals');
      if (stored) {
        try { return JSON.parse(stored); } catch (e) {}
      }
    }
    return [
      { id: "flash-1", badge: "100% BONUS", badgeColor: "#ec4899", diamondAmount: "100 DIAMONDS", diamonds: 100, price: "৳ 80.00", bonus: "+100 Free", btnStyle: "gold" },
      { id: "flash-2", badge: "POPULAR", badgeColor: "#e11d48", diamondAmount: "310 DIAMONDS", diamonds: 310, price: "৳ 270.00", bonus: "+31 Free", btnStyle: "navy" },
      { id: "flash-3", badge: "BEST VALUE", badgeColor: "#db2777", diamondAmount: "520 DIAMONDS", diamonds: 520, price: "৳ 420.00", bonus: "+52 Free", btnStyle: "gold" },
      { id: "flash-4", badge: "LIMITED", badgeColor: "#dc2626", diamondAmount: "1060 DIAMONDS", diamonds: 1060, price: "৳ 820.00", bonus: "+106 Free", btnStyle: "gold" },
      { id: "flash-5", badge: "MEGA DEAL", badgeColor: "#7c3aed", diamondAmount: "2180 DIAMONDS", diamonds: 2180, price: "৳ 1650.00", bonus: "+218 Free", btnStyle: "navy" },
      { id: "flash-6", badge: "VIP DEAL", badgeColor: "#2563eb", diamondAmount: "5600 DIAMONDS", diamonds: 5600, price: "৳ 4100.00", bonus: "+560 Free", btnStyle: "gold" }
    ];
  }

  saveFlashDeals(deals) {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_flash_deals', JSON.stringify(deals));
    }
  }

  addFlashDeal(deal) {
    const deals = this.getFlashDeals();
    deals.push({ id: `flash-${Date.now()}`, ...deal });
    this.saveFlashDeals(deals);
    return deals;
  }

  updateFlashDeal(id, updatedData) {
    const deals = this.getFlashDeals();
    const idx = deals.findIndex(d => d.id === id);
    if (idx !== -1) {
      deals[idx] = { ...deals[idx], ...updatedData };
      this.saveFlashDeals(deals);
    }
    return deals;
  }

  deleteFlashDeal(id) {
    let deals = this.getFlashDeals();
    deals = deals.filter(d => d.id !== id);
    this.saveFlashDeals(deals);
    return deals;
  }

  // --- POPULAR SERVICES (3-COL GRID) MANAGEMENT ---
  getPopularServices() {
    if (typeof localStorage !== 'undefined') {
      const stored = localStorage.getItem('mobinx_popular_services');
      if (stored) {
        try { return JSON.parse(stored); } catch (e) {}
      }
    }
    return [
      { id: "topup", title: "TOP UP", image: "assets/images/service_topup.jpg", route: "topup", accentColor: "#2563eb" },
      { id: "shop", title: "SHOP", image: "assets/images/service_shop.jpg", route: "shop", accentColor: "#7c3aed" },
      { id: "downloads", title: "DOWNLOADS", image: "assets/images/service_downloads.jpg", route: "downloads", accentColor: "#10b981" },
      { id: "tournaments", title: "TOURNAMENTS", image: "assets/images/service_tournaments.jpg", route: "tournaments", accentColor: "#ea580c" },
      { id: "sensitivity", title: "SENSITIVITY MAKER", image: "assets/images/service_sensitivity.jpg", route: "sensitivity", accentColor: "#0284c7" },
      { id: "profile", title: "PROFILE", image: "assets/images/service_profile.jpg", route: "profile", accentColor: "#9333ea" }
    ];
  }

  savePopularServices(services) {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_popular_services', JSON.stringify(services));
    }
  }

  addPopularService(service) {
    const services = this.getPopularServices();
    services.push({ id: `service-${Date.now()}`, ...service });
    this.savePopularServices(services);
    return services;
  }

  updatePopularService(id, updatedData) {
    const services = this.getPopularServices();
    const idx = services.findIndex(s => s.id === id);
    if (idx !== -1) {
      services[idx] = { ...services[idx], ...updatedData };
      this.savePopularServices(services);
    }
    return services;
  }

  deletePopularService(id) {
    let services = this.getPopularServices();
    services = services.filter(s => s.id !== id);
    this.savePopularServices(services);
    return services;
  }

  // --- HERO BANNERS MANAGEMENT ---
  getHeroBanners() {
    if (typeof localStorage !== 'undefined') {
      const stored = localStorage.getItem('mobinx_hero_banners');
      if (stored) {
        try { return JSON.parse(stored); } catch (e) {}
      }
    }
    return [
      {
        id: "banner-1",
        image: "assets/images/banner_esports.jpg",
        actionRoute: "tournaments"
      },
      {
        id: "banner-2",
        image: "assets/images/banner_topup.jpg",
        actionRoute: "topup"
      },
      {
        id: "banner-3",
        image: "assets/images/banner_sensitivity.jpg",
        actionRoute: "sensitivity"
      }
    ];
  }

  saveHeroBanners(banners) {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_hero_banners', JSON.stringify(banners));
    }
  }

  addHeroBanner(banner) {
    const banners = this.getHeroBanners();
    banners.unshift({ id: `banner-${Date.now()}`, ...banner });
    this.saveHeroBanners(banners);
    return banners;
  }

  updateHeroBanner(id, updatedData) {
    const banners = this.getHeroBanners();
    const idx = banners.findIndex(b => b.id === id);
    if (idx !== -1) {
      banners[idx] = { ...banners[idx], ...updatedData };
      this.saveHeroBanners(banners);
    }
    return banners;
  }

  deleteHeroBanner(id) {
    let banners = this.getHeroBanners();
    banners = banners.filter(b => b.id !== id);
    this.saveHeroBanners(banners);
    return banners;
  }



  persistSession() {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_user_session', JSON.stringify(this.user));
    }
  }

  // --- AUTHENTICATION & LOGIN ---
  loginWithGoogle(email, username = '', extra = {}) {
    const cleanEmail = (email || '').trim().toLowerCase();
    const hasStorage = typeof localStorage !== 'undefined';
    const storedAdmin = hasStorage ? localStorage.getItem('mobinx_admin_email') : null;
    let isAdmin = false;

    if (!storedAdmin && hasStorage) {
      localStorage.setItem('mobinx_admin_email', cleanEmail);
      this.adminEmail = cleanEmail;
      isAdmin = true;
    } else if (storedAdmin && storedAdmin.toLowerCase() === cleanEmail) {
      isAdmin = true;
    }

    const displayName = username || cleanEmail.split('@')[0] || 'Player';
    const existingIndex = this.registeredUsers.findIndex(u => u.email.toLowerCase() === cleanEmail);

    if (existingIndex !== -1) {
      // Existing registered user login
      const existing = this.registeredUsers[existingIndex];
      this.user = {
        ...existing,
        username: displayName || existing.username,
        email: cleanEmail,
        isAdmin: isAdmin || existing.isAdmin,
        phone: extra.phone || existing.phone || '01711223344',
        ffUid: extra.ffUid || existing.ffUid || '198273918'
      };
      this.registeredUsers[existingIndex] = { ...this.user };
    } else {
      // New User Registration
      const newUserId = "MX-" + Math.floor(100000 + Math.random() * 900000);
      this.user = {
        id: newUserId,
        username: displayName,
        fullName: extra.fullName || displayName,
        email: cleanEmail,
        phone: extra.phone || '018' + Math.floor(10000000 + Math.random() * 90000000),
        ffUid: extra.ffUid || String(Math.floor(1000000000 + Math.random() * 9000000000)),
        role: isAdmin ? "System Administrator (Admin)" : "VIP Pro Member",
        isAdmin: isAdmin,
        status: "Active",
        avatar: "assets/images/avatar_user.jpg",
        level: 35,
        walletBalance: 250,
        diamonds: 100,
        referralCode: "MX" + displayName.toUpperCase().substring(0, 5) + "VIP",
        referralEarnings: 0,
        registeredDate: new Date().toISOString().split('T')[0],
        stats: {
          tournamentsJoined: 0,
          totalDownloads: 0,
          savedSensitivities: 0,
          referralsCount: 0
        }
      };
      this.registeredUsers.unshift({ ...this.user });
    }

    this.saveUsersDatabase();
    this.persistSession();
    this.setOnboardingCompleted(true);
    return this.user;
  }

  loginWithPhone(fullName, phone, ffUid = '') {
    const cleanPhone = (phone || '').trim();
    const cleanName = (fullName || 'Player').trim();
    const cleanUid = (ffUid || '').trim() || String(Math.floor(1000000000 + Math.random() * 9000000000));
    const generatedEmail = `${cleanName.toLowerCase().replace(/[^a-z0-9]/g, '')}_${cleanPhone.slice(-4)}@mobinx.app`;

    const existingIndex = this.registeredUsers.findIndex(u => u.phone === cleanPhone);

    if (existingIndex !== -1) {
      const existing = this.registeredUsers[existingIndex];
      this.user = {
        ...existing,
        fullName: cleanName,
        username: cleanName.replace(/\s+/g, '_'),
        phone: cleanPhone,
        ffUid: cleanUid
      };
      this.registeredUsers[existingIndex] = { ...this.user };
    } else {
      const newUserId = "MX-" + Math.floor(100000 + Math.random() * 900000);
      this.user = {
        id: newUserId,
        username: cleanName.replace(/\s+/g, '_'),
        fullName: cleanName,
        email: generatedEmail,
        phone: cleanPhone,
        ffUid: cleanUid,
        role: "VIP Pro Member",
        isAdmin: false,
        status: "Active",
        avatar: "assets/images/avatar_user.jpg",
        level: 28,
        walletBalance: 150,
        diamonds: 50,
        referralCode: "MX" + cleanName.toUpperCase().substring(0, 4) + "VIP",
        referralEarnings: 0,
        registeredDate: new Date().toISOString().split('T')[0],
        stats: {
          tournamentsJoined: 0,
          totalDownloads: 0,
          savedSensitivities: 0,
          referralsCount: 0
        }
      };
      this.registeredUsers.unshift({ ...this.user });
    }

    this.saveUsersDatabase();
    this.persistSession();
    this.setOnboardingCompleted(true);
    return this.user;
  }

  logout() {
    this.user = {
      ...defaultUser,
      id: "MX-GUEST",
      username: "Guest_Player",
      fullName: "Guest Player",
      email: "guest@mobinx.app",
      isAdmin: false,
      role: "Guest Player",
      walletBalance: 0,
      diamonds: 0
    };
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_user_session', JSON.stringify(this.user));
    }
    return this.user;
  }

  updateProfile(updates) {
    this.user = { ...this.user, ...updates };
    this.persistSession();
    
    // Sync with registered users
    const idx = this.registeredUsers.findIndex(u => u.id === this.user.id);
    if (idx !== -1) {
      this.registeredUsers[idx] = { ...this.registeredUsers[idx], ...updates };
      this.saveUsersDatabase();
    }
    return this.user;
  }

  saveSensitivity(sensData) {
    const newEntry = {
      id: 'sens-' + Date.now(),
      savedAt: new Date().toLocaleDateString(),
      ...sensData
    };
    this.savedSensitivities.unshift(newEntry);
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('mobinx_saved_sens', JSON.stringify(this.savedSensitivities));
    }
    if (this.user && this.user.stats) {
      this.user.stats.savedSensitivities = this.savedSensitivities.length;
      this.updateProfile({});
    }
    return newEntry;
  }

  getSavedSensitivities() {
    return this.savedSensitivities;
  }

  recordTournamentJoin(tournamentId) {
    if (this.user && this.user.stats) {
      this.user.stats.tournamentsJoined = (this.user.stats.tournamentsJoined || 0) + 1;
      this.updateProfile({});
    }
  }

  recordDownload(downloadId) {
    if (this.user && this.user.stats) {
      this.user.stats.totalDownloads = (this.user.stats.totalDownloads || 0) + 1;
      this.updateProfile({});
    }
  }

  clearAppCache() {
    if (typeof localStorage !== 'undefined') {
      localStorage.removeItem('mobinx_saved_sens');
    }
    this.savedSensitivities = [];
    return true;
  }
}

export const authService = new AuthService();

