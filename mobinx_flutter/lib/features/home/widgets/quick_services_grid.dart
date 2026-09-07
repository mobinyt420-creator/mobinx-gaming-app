import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Interactive 4-Grid of Core Mobin X Gaming Services
class QuickServicesGrid extends StatelessWidget {
  final Function(int targetTab) onServiceSelect;
  final VoidCallback onSensitivityTap;

  const QuickServicesGrid({
    super.key,
    required this.onServiceSelect,
    required this.onSensitivityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'GAMING SERVICES',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            Text(
              'HIGH PERFORMANCE',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.cyanLight,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _buildServiceItem(
              title: 'Tournaments',
              subtitle: 'Custom Rooms & Cups',
              icon: Icons.emoji_events_rounded,
              color: AppColors.gold,
              imagePath: 'assets/images/service_tournaments.jpg',
              onTap: () => onServiceSelect(1),
            ),
            _buildServiceItem(
              title: 'Diamond Top-Up',
              subtitle: 'Instant BD bKash/Nagad',
              icon: Icons.diamond_rounded,
              color: AppColors.cyanLight,
              imagePath: 'assets/images/service_topup.jpg',
              onTap: () => onServiceSelect(2),
            ),
            _buildServiceItem(
              title: 'APK & Tools',
              subtitle: 'VIP Boosters & Lag Fix',
              icon: Icons.download_rounded,
              color: AppColors.emerald,
              imagePath: 'assets/images/service_downloads.jpg',
              onTap: () => onServiceSelect(3),
            ),
            _buildServiceItem(
              title: 'Sensitivity Maker',
              subtitle: 'Headshot Calibration',
              icon: Icons.track_changes_rounded,
              color: AppColors.purple,
              imagePath: 'assets/images/service_sensitivity.jpg',
              onTap: onSensitivityTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle faded background artwork
            Positioned(
              right: -15,
              bottom: -15,
              width: 85,
              height: 85,
              child: Opacity(
                opacity: 0.22,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        child: Icon(icon, size: 18, color: color),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
