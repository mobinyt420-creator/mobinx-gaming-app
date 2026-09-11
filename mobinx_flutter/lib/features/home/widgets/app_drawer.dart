import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';

/// Slide-Out Navigation Drawer with Staggered Entrance Animations
class AppDrawer extends StatefulWidget {
  final Function(String route) onNavigate;

  const AppDrawer({
    super.key,
    required this.onNavigate,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Function(String route) get onNavigate => widget.onNavigate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ValueListenableBuilder(
        valueListenable: AuthService.instance.userNotifier,
        builder: (context, user, _) {
          final userName = user?.name.isNotEmpty == true ? user!.name : 'Player';
          final userEmail = user?.email.isNotEmpty == true ? user!.email : 'player@mobinx.gaming';
          final userId = user?.id.isNotEmpty == true ? user!.id : 'MX-001';

          return Column(
            children: [
              // Drawer Header with User Profile
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User Avatar
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: (user != null && user.avatar.isNotEmpty && user.avatar.startsWith('http'))
                                ? CachedNetworkImage(
                                    imageUrl: user.avatar,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Container(color: Colors.white24),
                                    errorWidget: (_, _, _) => Image.asset(
                                      'assets/images/avatar_user.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/avatar_user.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ID: $userId',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Drawer Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.home_rounded,
                      title: 'Home',
                      index: 0,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('home');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.emoji_events_rounded,
                      title: 'BR Matches & Tournaments',
                      index: 1,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('tournaments');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.diamond_rounded,
                      title: 'Diamond Top-Up (noobtopup.com)',
                      index: 2,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('topup');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.shopping_cart_rounded,
                      title: 'VIP Shop (obinshop.com)',
                      index: 3,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('shop');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.download_rounded,
                      title: 'APK & Tools Download',
                      index: 4,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('downloads');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.tune_rounded,
                      title: 'VIP Sensitivity Maker',
                      index: 5,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('sensitivity');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.card_giftcard_rounded,
                      title: 'Refer & Earn Program',
                      iconColor: const Color(0xFF7C3AED),
                      index: 6,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('referral');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications_active_rounded,
                      title: 'Notification Center',
                      iconColor: const Color(0xFFF59E0B),
                      index: 7,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('notifications');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.person_rounded,
                      title: 'My Profile & UID',
                      index: 8,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('profile');
                      },
                    ),

                    if (user?.isAdmin == true) ...[
                      const Divider(color: AppColors.borderLight, height: 16),
                      _buildDrawerItem(
                        icon: Icons.admin_panel_settings_rounded,
                        title: '👑 Admin Dashboard Console',
                        iconColor: const Color(0xFFDC2626),
                        index: 9,
                        onTap: () {
                          Navigator.of(context).pop();
                          onNavigate('admin');
                        },
                      ),
                    ],

                    const Divider(color: AppColors.borderLight, height: 20),

                    _buildDrawerItem(
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      iconColor: AppColors.textSecondary,
                      index: 10,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('settings');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support 24/7',
                      iconColor: const Color(0xFF10B981),
                      index: 11,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('help');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About Mobin X',
                      iconColor: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('about');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.telegram,
                      title: 'Telegram Community',
                      iconColor: const Color(0xFF0284C7),
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('telegram');
                      },
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      'v${AppConstants.appVersion}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    int index = 0,
  }) {
    final delay = (index * 0.06).clamp(0.0, 0.7);
    final end = (delay + 0.3).clamp(0.0, 1.0);
    final slideAnim = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Interval(delay, end, curve: Curves.easeOutCubic),
    ));
    final fadeAnim = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(delay, end, curve: Curves.easeOut),
    );

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: ListTile(
          leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: onTap,
        ),
      ),
    );
  }
}
