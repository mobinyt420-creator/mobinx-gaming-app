import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/gamer_components.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/home_data_service.dart';
import '../../core/models/banner_model.dart';
import '../../core/models/tournament_model.dart';
import '../profile/profile_screen.dart';
import 'widgets/hero_banner_carousel.dart';
import 'widgets/quick_services_grid.dart';
import 'widgets/flash_deals_section.dart';
import 'widgets/featured_tournaments_section.dart';
import 'widgets/notice_modal.dart';
import 'widgets/sensitivity_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize Home Data Service
    HomeDataService.instance.init();

    // Check & display dynamic in-app notice modal if eligible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notice = HomeDataService.instance.activeNoticeNotifier.value;
      if (notice != null && mounted) {
        NoticeModal.showIfEligible(context, notice);
      }
    });
  }

  void _handleBannerTap(BannerModel banner) {
    final route = banner.actionUrl.toLowerCase().trim();
    if (route == 'tournaments') {
      setState(() => _currentNavIndex = 1);
    } else if (route == 'topup') {
      setState(() => _currentNavIndex = 2);
    } else if (route == 'downloads') {
      setState(() => _currentNavIndex = 3);
    } else if (route == 'telegram') {
      _openUrl(AppConstants.communityTelegram);
    } else if (route.startsWith('http://') || route.startsWith('https://')) {
      _openUrl(route);
    } else {
      setState(() => _currentNavIndex = 1);
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $url'), backgroundColor: AppColors.danger),
          );
        }
      }
    } catch (e) {
      debugPrint('[HomeScreen] Open URL error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.gamerGlowGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'M',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'GAMING ECOSYSTEM',
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cyanLight,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Notification Bell with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textMain),
                onPressed: () {
                  final notice = HomeDataService.instance.activeNoticeNotifier.value;
                  if (notice != null) {
                    showDialog(
                      context: context,
                      builder: (ctx) => NoticeModal(notice: notice),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔔 No new announcements right now.'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.surfaceCard,
                      ),
                    );
                  }
                },
              ),
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentNavIndex == 4 ? AppColors.cyanLight : AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceCard,
                    backgroundImage: (user != null && user.avatar.isNotEmpty && user.avatar.startsWith('http'))
                        ? NetworkImage(user.avatar)
                        : null,
                    child: (user == null || user.avatar.isEmpty || !user.avatar.startsWith('http'))
                        ? Text(
                            (user != null && user.name.isNotEmpty ? user.name[0] : 'U').toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              color: AppColors.cyanLight,
                              fontSize: 13,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentNavIndex = idx);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.diamond_outlined),
            selectedIcon: Icon(Icons.diamond_rounded),
            label: 'Top-Up',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download_rounded),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildPlaceholderTab('🏆 Tournaments & Matches', 'Free Fire Custom Tournaments will launch in Step 4!');
      case 2:
        return _buildPlaceholderTab('💎 Diamond Top-Up Shop', 'Instant bKash/Nagad Diamond Top-Up will launch in Step 5!');
      case 3:
        return _buildPlaceholderTab('🚀 APK Tools & Sensitivity', 'Secure Downloader & Sensitivity Generator will launch in Step 6!');
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildPlaceholderTab(String title, String desc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GamerCard(
          padding: const EdgeInsets.all(24),
          borderColor: AppColors.cyanLight.withValues(alpha: 0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              const GamerBadge(
                text: 'COMING IN NEXT STEPS',
                color: AppColors.cyanLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () => HomeDataService.instance.refresh(),
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceCard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Auto-Scrolling Banner Carousel
            ValueListenableBuilder<List<BannerModel>>(
              valueListenable: HomeDataService.instance.bannersNotifier,
              builder: (context, banners, _) {
                return HeroBannerCarousel(
                  banners: banners,
                  onBannerTap: _handleBannerTap,
                );
              },
            ),
            const SizedBox(height: 20),

            // 2. High-Density Quick Services Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuickServicesGrid(
                onServiceSelect: (tabIndex) {
                  setState(() => _currentNavIndex = tabIndex);
                },
                onSensitivityTap: () {
                  SensitivitySheet.show(context);
                },
              ),
            ),
            const SizedBox(height: 22),

            // 3. Flash Diamond Top-Up Deals Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<List<FlashDealModel>>(
                valueListenable: HomeDataService.instance.flashDealsNotifier,
                builder: (context, deals, _) {
                  return FlashDealsSection(
                    deals: deals,
                    onDealTap: (deal) {
                      setState(() => _currentNavIndex = 2);
                    },
                    onViewAllTap: () {
                      setState(() => _currentNavIndex = 2);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // 4. Featured Tournaments & Custom Rooms
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<List<TournamentModel>>(
                valueListenable: HomeDataService.instance.featuredTournamentsNotifier,
                builder: (context, tourns, _) {
                  return FeaturedTournamentsSection(
                    tournaments: tourns,
                    onTournamentTap: (tourn) {
                      setState(() => _currentNavIndex = 1);
                    },
                    onViewAllTap: () {
                      setState(() => _currentNavIndex = 1);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // 5. Official Community & Support Links
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCommunityCard(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard() {
    return GamerCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.cyanLight.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hub_rounded, color: AppColors.cyanLight, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OFFICIAL COMMUNITY HUB',
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Get Daily Redeem Codes & Match Passes',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.send_rounded, size: 16, color: AppColors.cyanLight),
                  label: Text(
                    'TELEGRAM',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyanLight,
                    side: const BorderSide(color: AppColors.cyanLight, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => _openUrl(AppConstants.communityTelegram),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.support_agent_rounded, size: 16, color: AppColors.gold),
                  label: Text(
                    'SUPPORT',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => _openUrl(AppConstants.supportTelegram),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
