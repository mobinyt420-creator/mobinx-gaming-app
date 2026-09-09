import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/home_data_service.dart';
import '../../core/services/store_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/banner_model.dart';
import '../downloads/downloads_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../tournaments/tournaments_screen.dart';
import '../sensitivity/sensitivity_screen.dart';
import '../referral/referral_screen.dart';
import '../help/help_screen.dart';
import '../settings/settings_screen.dart';
import '../about/about_screen.dart';
import 'widgets/hero_banner_carousel.dart';
import 'widgets/category_slider.dart';
import 'widgets/popular_services_grid.dart';
import 'widgets/flash_deals_section.dart';
import 'widgets/promo_banners_grid.dart';
import 'widgets/app_drawer.dart';

/// Main Mobin X Navigation & Home Hub (Exact Alignment with Screenshot 1)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    HomeDataService.instance.init();
    StoreService.instance.init();
    NotificationService.instance.init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleBannerTap(BannerModel banner) {
    final route = banner.actionUrl.toLowerCase().trim();
    _handleRoute(route);
  }

  void _handleRoute(String route) {
    if (route == 'home') {
      setState(() => _currentNavIndex = 0);
    } else if (route == 'topup') {
      StoreService.instance.openTopUp();
    } else if (route == 'shop') {
      StoreService.instance.openShop();
    } else if (route == 'downloads') {
      setState(() => _currentNavIndex = 3);
    } else if (route == 'tournaments') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TournamentsScreen(onBack: () => Navigator.pop(context))),
      );
    } else if (route == 'sensitivity') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SensitivityScreen(onBack: () => Navigator.pop(context))),
      );
    } else if (route == 'referral') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReferralScreen()),
      );
    } else if (route == 'notifications') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    } else if (route == 'help') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HelpScreen()),
      );
    } else if (route == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    } else if (route == 'about') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AboutScreen()),
      );
    } else if (route == 'admin') {
      StoreService.instance.openUrlInBrowserView(
        'https://mobinx-admin-console.vercel.app',
        title: 'Mobin X Admin Console',
        barColor: const Color(0xFF1E1B4B),
      );
    } else if (route == 'profile') {
      setState(() => _currentNavIndex = 4);
    } else if (route == 'telegram') {
      _openUrl(AppConstants.communityTelegram);
    } else if (route.startsWith('http://') || route.startsWith('https://')) {
      _openUrl(route);
    }
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: AppDrawer(
        onNavigate: _handleRoute,
      ),
      appBar: _currentNavIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              scrolledUnderElevation: 0,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1.0),
                child: Divider(height: 1.0, color: AppColors.borderLight),
              ),
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textMain, size: 24),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'M',
                        style: TextStyle(
                          color: Color(0xFF0284C7),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              actions: [
                // Notification Bell with Badge '4' (Image 1)
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textMain, size: 23),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: NotificationService.instance.unreadCountNotifier,
                      builder: (context, unreadCount, _) {
                        if (unreadCount <= 0) return const SizedBox.shrink();
                        return Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // User Avatar Button -> Profile
                ValueListenableBuilder(
                  valueListenable: AuthService.instance.userNotifier,
                  builder: (context, user, _) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _currentNavIndex = 4);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 4, right: 14),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4F46E5),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: Image.asset(
                            'assets/images/avatar_user.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                (user != null && user.name.isNotEmpty ? user.name[0] : 'M').toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    final stackIndex = _currentNavIndex == 3 ? 1 : (_currentNavIndex == 4 ? 2 : 0);
    return IndexedStack(
      index: stackIndex,
      children: [
        _buildHomeTab(),
        DownloadsScreen(onBack: () => setState(() => _currentNavIndex = 0)),
        const ProfileScreen(),
      ],
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () => HomeDataService.instance.refresh(),
      color: const Color(0xFF2563EB),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero 16:9 Banner Slider
            ValueListenableBuilder<List<BannerModel>>(
              valueListenable: HomeDataService.instance.bannersNotifier,
              builder: (context, banners, _) {
                return HeroBannerCarousel(
                  banners: banners,
                  onBannerTap: _handleBannerTap,
                );
              },
            ),
            const SizedBox(height: 8),

            // 2. Quick 4-Category Shortcuts (Downloads, Tournaments, Top Up, Shop)
            CategorySlider(
              onCategoryTap: _handleRoute,
            ),
            const SizedBox(height: 8),

            // 3. Popular Services Grid (2x3 Grid matching Screenshot 1)
            PopularServicesGrid(
              onServiceTap: _handleRoute,
              onViewAllTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(height: 10),

            // 4. Flash Diamond Top Up Section with Countdown & Products
            ValueListenableBuilder<List<FlashDealModel>>(
              valueListenable: HomeDataService.instance.flashDealsNotifier,
              builder: (context, deals, _) {
                return FlashDealsSection(
                  deals: deals,
                  onDealTap: (deal) => StoreService.instance.openTopUp(),
                  onViewAllTap: () => StoreService.instance.openTopUp(),
                );
              },
            ),
            const SizedBox(height: 10),

            // 5. Mini Promotional Banners (Telegram & Special Offers)
            PromoBannersGrid(
              onTelegramTap: () => _openUrl(AppConstants.communityTelegram),
              onSpecialOffersTap: () => StoreService.instance.openTopUp(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final tabs = [
      {'id': 'home', 'label': 'Home', 'icon': Icons.home_rounded, 'outlined': Icons.home_outlined},
      {'id': 'topup', 'label': 'Top Up', 'icon': Icons.diamond, 'outlined': Icons.diamond_outlined},
      {'id': 'shop', 'label': 'Shop', 'icon': Icons.shopping_cart, 'outlined': Icons.shopping_cart_outlined},
      {'id': 'downloads', 'label': 'Downloads', 'icon': Icons.file_download_outlined, 'outlined': Icons.file_download_outlined},
      {'id': 'profile', 'label': 'Profile', 'icon': Icons.person_outline_rounded, 'outlined': Icons.person_outline_rounded},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(tabs.length, (idx) {
            final isSelected = _currentNavIndex == idx;
            final tab = tabs[idx];

            return Expanded(
              child: InkWell(
                onTap: () {
                  if (idx == 1) {
                    // Top Up -> Opens Webview/Chrome Custom Tab (Screenshot 3)
                    StoreService.instance.openTopUp();
                  } else if (idx == 2) {
                    // Shop -> Opens Webview/Chrome Custom Tab
                    StoreService.instance.openShop();
                  } else {
                    setState(() => _currentNavIndex = idx);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? (tab['icon'] as IconData) : (tab['outlined'] as IconData),
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
