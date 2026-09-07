import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/tournament_model.dart';
import '../../../core/widgets/gamer_components.dart';

/// Featured Esports & Free Fire Tournaments Section on Home
class FeaturedTournamentsSection extends StatelessWidget {
  final List<TournamentModel> tournaments;
  final Function(TournamentModel tournament) onTournamentTap;
  final VoidCallback onViewAllTap;

  const FeaturedTournamentsSection({
    super.key,
    required this.tournaments,
    required this.onTournamentTap,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'UPCOMING TOURNAMENTS',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                const GamerBadge(
                  text: 'LIVE BR',
                  color: AppColors.danger,
                  icon: Icons.fiber_manual_record,
                ),
              ],
            ),
            TextButton(
              onPressed: onViewAllTap,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Row(
                children: [
                  Text(
                    'VIEW ALL',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cyanLight,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.cyanLight),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Tournament Cards List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tournaments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tourn = tournaments[index];
            return _buildTournamentCard(tourn);
          },
        ),
      ],
    );
  }

  Widget _buildTournamentCard(TournamentModel tourn) {
    final double fillPercentage = tourn.slotsTotal > 0
        ? (tourn.slotsFilled / tourn.slotsTotal).clamp(0.0, 1.0)
        : 0.0;

    return GamerCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.gold.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Badges & Prize Pool
          Row(
            children: [
              GamerBadge(
                text: tourn.mode.toUpperCase(),
                color: AppColors.cyanLight,
                icon: Icons.sports_esports_rounded,
              ),
              const SizedBox(width: 6),
              GamerBadge(
                text: tourn.map.toUpperCase(),
                color: AppColors.emerald,
                icon: Icons.map_rounded,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, size: 14, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      tourn.prizePool,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            tourn.title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Match Time
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                tourn.matchTime,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Entry: ${tourn.entryFee}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: tourn.entryFee.toLowerCase().contains('free')
                      ? AppColors.emerald
                      : AppColors.cyanLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slots Progress Bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fillPercentage,
                        backgroundColor: AppColors.surfaceBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          fillPercentage > 0.8 ? AppColors.danger : AppColors.cyanLight,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tourn.slotsFilled}/${tourn.slotsTotal} Slots Filled (${(fillPercentage * 100).toInt()}%)',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              GamerButton(
                label: 'JOIN MATCH',
                width: 105,
                height: 34,
                onPressed: () => onTournamentTap(tourn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
