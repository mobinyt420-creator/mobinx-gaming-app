import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gamer_components.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: AppColors.borderLight),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNoticeCard(
            title: 'Welcome to Mobin X Super App',
            body: 'Enjoy the new pure Flutter experience with ultra fast speeds, instant diamond top-ups, and live tournaments!',
            time: '2 hours ago',
            isNew: true,
          ),
          const SizedBox(height: 12),
          _buildNoticeCard(
            title: 'Free Diamond Giveaway',
            body: 'Join the Official Telegram to claim 115 Free Diamonds tonight at 9 PM!',
            time: '1 day ago',
            isNew: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard({
    required String title,
    required String body,
    required String time,
    required bool isNew,
  }) {
    return GamerCard(
      padding: const EdgeInsets.all(16),
      borderColor: isNew ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              if (isNew)
                const GamerBadge(text: 'NEW', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textBody,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
