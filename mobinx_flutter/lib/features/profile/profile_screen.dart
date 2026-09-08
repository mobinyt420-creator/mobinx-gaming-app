import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/store_service.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/gamer_components.dart';
import '../auth/onboarding_screen.dart';
import '../tournaments/tournaments_screen.dart';
import '../sensitivity/sensitivity_screen.dart';
import '../referral/referral_screen.dart';
import '../help/help_screen.dart';
import '../settings/settings_screen.dart';
import '../about/about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openEditProfileDialog(UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final ffUidCtrl = TextEditingController(text: user.ffUid);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Edit Player Profile',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Player Name / IGN', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              const SizedBox(height: 5),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textMain, fontSize: 13.5),
                decoration: const InputDecoration(hintText: 'Your In-Game Name'),
              ),
              const SizedBox(height: 12),

              Text('Phone Number', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              const SizedBox(height: 5),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.textMain, fontSize: 13.5),
                decoration: const InputDecoration(hintText: '01XXXXXXXXX'),
              ),
              const SizedBox(height: 12),

              Text('Free Fire UID', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              const SizedBox(height: 5),
              TextField(
                controller: ffUidCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textMain, fontSize: 13.5),
                decoration: const InputDecoration(hintText: 'e.g. 1234567890'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = user.copyWith(
                name: nameCtrl.text.trim(),
                username: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                ffUid: ffUidCtrl.text.trim(),
              );
              AuthService.instance.userNotifier.value = updated;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Profile updated successfully!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textMain),
        ),
        content: const Text(
          'Are you sure you want to sign out of your Mobin X account?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: AuthService.instance.userNotifier,
      builder: (context, user, child) {
        if (user == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Not Signed In',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                ),
                const SizedBox(height: 6),
                const Text('Sign in to manage your gaming profile and tournaments.', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 18),
                GamerButton(
                  label: 'Sign In / Register',
                  width: 180,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Profile Card (Modern Light Theme Hero Card)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar with ring
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.brandGradient,
                              border: Border.all(color: AppColors.primaryLight, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M',
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Name, Player Number & Badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMain,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: user.isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: user.isAdmin ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            user.isAdmin ? Icons.verified_user_rounded : Icons.star_rounded,
                                            size: 13,
                                            color: user.isAdmin ? const Color(0xFFD97706) : AppColors.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            user.isAdmin ? 'ADMIN' : 'VIP PRO',
                                            style: GoogleFonts.outfit(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w900,
                                              color: user.isAdmin ? const Color(0xFFD97706) : AppColors.primary,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '#${user.playerNumber.toString().padLeft(4, '0')}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                            onPressed: () => _openEditProfileDialog(user),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: AppColors.borderLight),
                      const SizedBox(height: 10),

                      // Free Fire UID Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.videogame_asset_outlined, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Free Fire UID:',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              if (user.ffUid.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: user.ffUid));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied Free Fire UID to clipboard!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                _openEditProfileDialog(user);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: user.ffUid.isNotEmpty ? AppColors.surfaceCardSubtle : AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: user.ffUid.isNotEmpty ? AppColors.borderLight : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    user.ffUid.isNotEmpty ? user.ffUid : 'Set UID +',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: user.ffUid.isNotEmpty ? AppColors.textMain : Colors.white,
                                    ),
                                  ),
                                  if (user.ffUid.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.copy_rounded, size: 12, color: AppColors.textMuted),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Referral Program Banner Card (Replacing Unnecessary Wallet Balance)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReferralScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF31104B), Color(0xFF6B21A8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B21A8).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('🎁', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Referral Program & Rewards',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Invite code: ${user.referralCode} • Earn diamonds',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'INVITE ›',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF6B21A8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

              // Player Esports Stats Grid
              Text(
                '📊 Esports Performance & Stats',
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatBox('Tournaments', '${user.tournamentsJoined}', Icons.emoji_events_outlined, const Color(0xFFF59E0B)),
                  const SizedBox(width: 10),
                  _buildStatBox('Downloads', '${user.totalDownloads}', Icons.download_outlined, const Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  _buildStatBox('Sensitivities', '${user.savedSensitivities}', Icons.track_changes_outlined, const Color(0xFF0284C7)),
                ],
              ),
              const SizedBox(height: 24),

              // Profile Quick Actions & Features
              Text(
                '🎯 Quick Actions & Features',
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 10),

              _buildSettingsTile(
                icon: Icons.emoji_events_rounded,
                title: 'My Tournaments & Matches',
                subtitle: 'View joined rooms, match schedules & prize claim status',
                iconColor: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TournamentsScreen(onBack: () => Navigator.pop(context))),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.tune_rounded,
                title: 'Saved Aim Presets & Sensitivity Maker',
                subtitle: 'Calibrate your phone for 100% headshot accuracy',
                iconColor: const Color(0xFF2563EB),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SensitivityScreen(onBack: () => Navigator.pop(context))),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.card_giftcard_rounded,
                title: 'Referral Program & Rewards',
                subtitle: 'Invite friends, earn diamonds & instant bKash rewards',
                iconColor: const Color(0xFF7C3AED),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReferralScreen()),
                  );
                },
              ),

              if (user.isAdmin) ...[
                const SizedBox(height: 14),
                Text(
                  '👑 Administrator Management',
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSettingsTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Open Admin Dashboard Console',
                  subtitle: 'Real-time banners, rooms, users, downloads & finance',
                  iconColor: const Color(0xFFDC2626),
                  onTap: () {
                    StoreService.instance.openUrlInBrowserView(
                      'https://mobinx-admin-console.vercel.app',
                      title: 'Mobin X Admin Console',
                      barColor: const Color(0xFF1E1B4B),
                    );
                  },
                ),
              ],

              const SizedBox(height: 16),

              // Settings & Actions List
              Text(
                '⚙️ Account Settings',
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 10),

              _buildSettingsTile(
                icon: Icons.settings_rounded,
                title: 'App Settings & Preferences',
                subtitle: 'Push notifications, sound alerts & cache manager',
                iconColor: AppColors.textSecondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support 24/7',
                subtitle: 'WhatsApp, Telegram, live tickets & FAQs',
                iconColor: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About Mobin X',
                subtitle: 'Version details, studio credits & security shield',
                iconColor: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                subtitle: 'Logout from this Android device',
                iconColor: AppColors.danger,
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
