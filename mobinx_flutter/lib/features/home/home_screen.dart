import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/page_transitions.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/home_data_service.dart';
import '../../core/services/store_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/download_service.dart';
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
    DownloadService.instance.init();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isGranted = await NotificationService.instance.isPermissionGranted();
      if (!isGranted) {
        await NotificationService.instance.requestPermission();
      }
    });
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
        SharedAxisPageRoute(page: TournamentsScreen(onBack: () => Navigator.pop(context))),
      );
    } else if (route == 'sensitivity') {
      Navigator.push(
        context,
        SharedAxisPageRoute(page: SensitivityScreen(onBack: () => Navigator.pop(context))),
      );
    } else if (route == 'referral') {
      Navigator.push(
        context,
        SharedAxisPageRoute(page: const ReferralScreen()),
      );
    } else if (route == 'notifications') {
      NotificationService.instance.markAllAsRead();
      Navigator.push(
        context,
        SharedAxisPageRoute(page: const NotificationsScreen()),
      );
    } else if (route == 'help') {
      Navigator.push(
        context,
        SharedAxisPageRoute(page: const HelpScreen()),
      );
    } else if (route == 'settings') {
      Navigator.push(
        context,
        SharedAxisPageRoute(page: const SettingsScreen()),
      );
    } else if (route == 'about') {
      Navigator.push(
        context,
        SharedAxisPageRoute(page: const AboutScreen()),
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Transform.scale(
                      scale: 1.15,
                      child: Image.asset(
                        'assets/images/obin_icon_512.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  // Stylized OBIN Logo with Cyan 'O', Dark Navy 'BIN' & Swoosh Wave (Image 1)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'O',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF00A3FF),
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'BIN',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0B1936),
                                letterSpacing: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      CustomPaint(
                        size: const Size(62, 3.5),
                        painter: _ObinAppBarSwooshPainter(),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Notification Bell with Badge (Image 1)
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_rounded, color: Color(0xFF0F172A), size: 26),
                      onPressed: () {
                        NotificationService.instance.markAllAsRead();
                        Navigator.push(
                          context,
                          SharedAxisPageRoute(page: const NotificationsScreen()),
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
                          child: (user != null && user.avatar.isNotEmpty && user.avatar.startsWith('http'))
                              ? CachedNetworkImage(
                                  imageUrl: user.avatar,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => Container(color: const Color(0xFFEEF2FF)),
                                  errorWidget: (_, _, _) => _buildHeaderInitialsAvatar(user),
                                )
                              : (user != null && user.name.isNotEmpty)
                                  ? _buildHeaderInitialsAvatar(user)
                                  : Image.asset(
                                      'assets/images/avatar_user.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _buildHeaderInitialsAvatar(user),
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
    if (_currentNavIndex == 3) {
      return DownloadsScreen(onBack: () => setState(() => _currentNavIndex = 0));
    }
    if (_currentNavIndex == 4) {
      return const ProfileScreen();
    }
    return _buildHomeTab();
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () => HomeDataService.instance.refresh(),
      color: const Color(0xFF2563EB),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(tabs.length, (idx) {
            final isSelected = _currentNavIndex == idx;
            final tab = tabs[idx];

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (idx == 1) {
                    StoreService.instance.openTopUp();
                  } else if (idx == 2) {
                    StoreService.instance.openShop();
                  } else {
                    setState(() => _currentNavIndex = idx);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: AnimatedScale(
                    scale: isSelected ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated pill indicator above icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOutCubic,
                          width: isSelected ? 20 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? (tab['icon'] as IconData) : (tab['outlined'] as IconData),
                            key: ValueKey<bool>(isSelected),
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.inter(
                            fontSize: isSelected ? 11 : 10.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                          ),
                          child: Text(tab['label'] as String),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeaderInitialsAvatar(dynamic user) {
    final String initial = (user != null && user.name != null && user.name.toString().trim().isNotEmpty)
        ? user.name.toString().trim()[0].toUpperCase()
        : 'M';
    return Container(
      color: const Color(0xFF4F46E5),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ObinAppBarSwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF0284C7), Color(0xFF38BDF8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..cubicTo(size.width * 0.2, size.height * 0.95, size.width * 0.7, size.height * 0.9, size.width, size.height * 0.05)
      ..cubicTo(size.width * 0.65, size.height * 0.55, size.width * 0.25, size.height * 0.45, 0, size.height * 0.3)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
