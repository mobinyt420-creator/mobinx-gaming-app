import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/tournament_model.dart';
import '../../../core/widgets/gamer_components.dart';
import 'room_credentials_dialog.dart';
import 'match_registration_sheet.dart';

/// Comprehensive High-Density Esports Tournament Card
class TournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  final VoidCallback onStateChanged;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double fillPercentage = tournament.slotsTotal > 0
        ? (tournament.slotsFilled / tournament.slotsTotal).clamp(0.0, 1.0)
        : 0.0;

    final isFull = tournament.slotsFilled >= tournament.slotsTotal;
    final isCompleted = tournament.status.toLowerCase() == 'completed';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tournament.isRegistered
              ? AppColors.emerald.withValues(alpha: 0.6)
              : (tournament.isLive
                  ? AppColors.danger.withValues(alpha: 0.6)
                  : AppColors.primary.withValues(alpha: 0.3)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (tournament.isRegistered
                    ? AppColors.emerald
                    : (tournament.isLive ? AppColors.danger : AppColors.primary))
                .withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tournament Banner Header (16:7 aspect ratio)
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildBannerImage(tournament.banner),

                // Dark gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),

                // Top badges
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: [
                      if (tournament.isLive)
                        const GamerBadge(
                          text: '🔴 LIVE NOW',
                          color: AppColors.danger,
                        )
                      else if (isCompleted)
                        const GamerBadge(
                          text: 'COMPLETED 🏁',
                          color: AppColors.textMuted,
                        )
                      else
                        const GamerBadge(
                          text: 'UPCOMING',
                          color: AppColors.cyanLight,
                          icon: Icons.schedule_rounded,
                        ),
                      if (tournament.isRegistered) ...[
                        const SizedBox(width: 6),
                        const GamerBadge(
                          text: 'YOU JOINED ✅',
                          color: AppColors.emerald,
                        ),
                      ],
                    ],
                  ),
                ),

                // Date badge on top right
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight, width: 0.8),
                    ),
                    child: Text(
                      tournament.date,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Mode & Map on bottom of banner
                Positioned(
                  bottom: 10,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      GamerBadge(
                        text: tournament.mode.toUpperCase(),
                        color: AppColors.cyanLight,
                        icon: Icons.sports_esports_rounded,
                      ),
                      const SizedBox(width: 6),
                      GamerBadge(
                        text: tournament.map.toUpperCase(),
                        color: AppColors.emerald,
                        icon: Icons.map_rounded,
                      ),
                      const Spacer(),
                      // Match Time
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 12, color: AppColors.goldLight),
                          const SizedBox(width: 4),
                          Text(
                            tournament.matchTime,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Tournament Details Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  tournament.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Rules Snippet
                Text(
                  tournament.rules,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Prize Pool & Entry Fee Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prize Pool
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL PRIZE',
                                style: GoogleFonts.outfit(fontSize: 8.5, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                              ),
                              Text(
                                tournament.prizePool,
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.gold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Entry Fee
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ENTRY FEE',
                            style: GoogleFonts.outfit(fontSize: 8.5, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                          ),
                          Text(
                            tournament.entryFee,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: tournament.entryFee.toLowerCase().contains('free')
                                  ? AppColors.emerald
                                  : AppColors.cyanLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Slots Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${tournament.slotsFilled}/${tournament.slotsTotal} Players Joined',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${(fillPercentage * 100).toInt()}% Filled',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: fillPercentage > 0.8 ? AppColors.danger : AppColors.cyanLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fillPercentage,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          fillPercentage > 0.8 ? AppColors.danger : AppColors.cyanLight,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. Dynamic Action Button
                _buildActionButton(context, isFull, isCompleted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isFull, bool isCompleted) {
    // 1. Registered and Room Credentials Released
    if (tournament.isRegistered && tournament.isRoomReleased) {
      return GamerButton(
        label: '🔑 VIEW ROOM ID & PASSWORD',
        color: AppColors.emerald,
        height: 44,
        onPressed: () {
          RoomCredentialsDialog.show(context, tournament);
        },
      );
    }

    // 2. Registered but Room Credentials not released yet
    if (tournament.isRegistered) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.emerald),
            const SizedBox(width: 8),
            Text(
              'REGISTERED (ROOM PASS OPENS 15M BEFORE)',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.emerald,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Match Completed
    if (isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Center(
          child: Text(
            'MATCH CONCLUDED 🏁',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    // 4. Slots Full
    if (isFull) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            'SLOTS FULL 🔒',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.danger,
            ),
          ),
        ),
      );
    }

    // 5. Default: Join Tournament
    return GamerButton(
      label: 'JOIN TOURNAMENT 🚀',
      height: 44,
      onPressed: () {
        MatchRegistrationSheet.show(
          context,
          tournament,
          onRegistered: onStateChanged,
        );
      },
    );
  }

  Widget _buildBannerImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: AppColors.surface),
        errorWidget: (context, url, error) => Image.asset('assets/images/banner_esports.jpg', fit: BoxFit.cover),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }
}
