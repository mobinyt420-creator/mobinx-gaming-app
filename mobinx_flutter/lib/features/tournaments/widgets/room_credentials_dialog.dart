import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/tournament_model.dart';
import '../../../core/widgets/gamer_components.dart';

/// Cyberpunk Room ID & Password Modal Dialog
class RoomCredentialsDialog extends StatelessWidget {
  final TournamentModel tournament;

  const RoomCredentialsDialog({
    super.key,
    required this.tournament,
  });

  static void show(BuildContext context, TournamentModel tournament) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => RoomCredentialsDialog(tournament: tournament),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 $label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  Future<void> _launchFreeFire(BuildContext context) async {
    // Attempt Free Fire deep link or playstore package intent
    final uri = Uri.parse('freefire://');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback: Open Free Fire on Google Play Store
        final playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.dts.freefiremax');
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎮 Please open Free Fire game and paste Room ID & Password.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.surfaceCard,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.emerald.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.emerald.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Room Live Indicator & Close Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.key_rounded, color: AppColors.emerald, size: 22),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROOM CREDENTIALS',
                      style: GoogleFonts.outfit(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Free Fire Custom Match Room',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tournament Title & Mode
            Text(
              tournament.title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                GamerBadge(text: tournament.mode, color: AppColors.cyanLight),
                const SizedBox(width: 6),
                GamerBadge(text: tournament.map, color: AppColors.gold),
                const Spacer(),
                Text(
                  tournament.matchTime,
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Room ID Card
            _buildCredentialCard(
              context: context,
              title: 'CUSTOM ROOM ID',
              value: tournament.roomId.isNotEmpty ? tournament.roomId : 'GENERATING...',
              color: AppColors.cyanLight,
              onCopy: () => _copyToClipboard(context, tournament.roomId, 'Room ID'),
            ),
            const SizedBox(height: 12),

            // 2. Room Password Card
            _buildCredentialCard(
              context: context,
              title: 'ROOM PASSWORD',
              value: tournament.roomPass.isNotEmpty ? tournament.roomPass : 'NO PASSWORD',
              color: AppColors.gold,
              onCopy: () => _copyToClipboard(context, tournament.roomPass, 'Password'),
            ),
            const SizedBox(height: 16),

            // Match Rules Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight, width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.cyanLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Join the custom room within 10 minutes. Do not share credentials with unregistered players or your team will be disqualified.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action: Launch Free Fire
            GamerButton(
              label: 'OPEN FREE FIRE GAME 🎮',
              icon: Icons.sports_esports_rounded,
              onPressed: () => _launchFreeFire(context),
              height: 44,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.sourceCodePro(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          IconButton.filled(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 16),
            style: IconButton.styleFrom(
              backgroundColor: color.withValues(alpha: 0.2),
              foregroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
