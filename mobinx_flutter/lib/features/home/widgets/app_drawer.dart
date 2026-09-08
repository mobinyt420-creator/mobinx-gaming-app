import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';

/// Slide-Out Navigation Drawer (Matching DrawerMenu.js from website)
class AppDrawer extends StatelessWidget {
  final Function(String route) onNavigate;

  const AppDrawer({
    super.key,
    required this.onNavigate,
  });

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
              // Drawer Header with Royal Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                            child: Image.asset(
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
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('home');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.emoji_events_rounded,
                      title: 'BR Matches & Tournaments',
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('tournaments');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.diamond_rounded,
                      title: 'Diamond Top-Up (noobtopup.com)',
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('topup');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.shopping_cart_rounded,
                      title: 'VIP Shop (obinshop.com)',
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('shop');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.download_rounded,
                      title: 'APK & Tools Download',
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('downloads');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.tune_rounded,
                      title: 'VIP Sensitivity Maker',
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('sensitivity');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.card_giftcard_rounded,
                      title: 'Refer & Earn Program',
                      iconColor: const Color(0xFF7C3AED),
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('referral');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications_active_rounded,
                      title: 'Notification Center',
                      iconColor: const Color(0xFFF59E0B),
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('notifications');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.person_rounded,
                      title: 'My Profile & UID',
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
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate('settings');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support 24/7',
                      iconColor: const Color(0xFF10B981),
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
  }) {
    return ListTile(
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
    );
  }
}
