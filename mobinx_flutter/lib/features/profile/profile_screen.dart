import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/gamer_components.dart';
import '../auth/onboarding_screen.dart';

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
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.cyanLight),
            const SizedBox(width: 8),
            Text(
              'Edit Player Profile',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Player Name / IGN', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 5),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: const InputDecoration(hintText: 'Your In-Game Name'),
              ),
              const SizedBox(height: 12),

              Text('Phone Number', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 5),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: const InputDecoration(hintText: '01XXXXXXXXX'),
              ),
              const SizedBox(height: 12),

              Text('Free Fire UID', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 5),
              TextField(
                controller: ffUidCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
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
            child: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        title: const Text('Logout Confirmation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out of your Mobin X account?', style: TextStyle(color: AppColors.textBody)),
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
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Profile Card
              GamerCard(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surfaceCard,
                    AppColors.primary.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar with glow
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.gamerGlowGradient,
                            border: Border.all(color: AppColors.cyanLight, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
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
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  GamerBadge(
                                    text: user.isAdmin ? '👑 ADMIN' : '⭐ VIP PRO',
                                    color: user.isAdmin ? AppColors.gold : AppColors.cyanLight,
                                    icon: user.isAdmin ? Icons.verified_user_rounded : Icons.star_rounded,
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
                          icon: const Icon(Icons.edit_outlined, color: AppColors.cyanLight),
                          onPressed: () => _openEditProfileDialog(user),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),

                    // Free Fire UID Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.videogame_asset_outlined, color: AppColors.cyanLight, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Free Fire UID:',
                              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  user.ffUid.isNotEmpty ? user.ffUid : 'Set UID +',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: user.ffUid.isNotEmpty ? Colors.white : AppColors.cyanLight,
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
              const SizedBox(height: 16),

              // Wallet & Balance Card
              GamerCard(
                borderColor: AppColors.gold.withValues(alpha: 0.35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet Balance',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '৳ ${user.walletBalance}.00',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.goldLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GamerButton(
                      label: 'Top-Up +',
                      width: 100,
                      height: 38,
                      gradient: AppColors.goldGradient,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('💎 Diamond Top-Up shop opens in Step 5!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Player Esports Stats Grid
              Text(
                '📊 Esports Performance & Stats',
                style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatBox('Tournaments', '${user.tournamentsJoined}', Icons.emoji_events_outlined, AppColors.gold),
                  const SizedBox(width: 10),
                  _buildStatBox('Downloads', '${user.totalDownloads}', Icons.download_outlined, AppColors.emerald),
                  const SizedBox(width: 10),
                  _buildStatBox('Sensitivities', '${user.savedSensitivities}', Icons.track_changes_outlined, AppColors.cyanLight),
                ],
              ),
              const SizedBox(height: 24),

              // Settings & Actions List
              Text(
                '⚙️ Account Settings',
                style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 10),

              _buildSettingsTile(
                icon: Icons.support_agent_rounded,
                title: 'Official Telegram Support',
                subtitle: 'Join 100K+ community for match passwords',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✈️ Telegram Community: @mobinx_official')),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy & Terms',
                subtitle: 'Google Play verified data safety policies',
                onTap: () {},
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
        );
      },
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GamerCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        borderColor: color.withValues(alpha: 0.25),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
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
    return GamerCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.cyanLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
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
    );
  }
}
