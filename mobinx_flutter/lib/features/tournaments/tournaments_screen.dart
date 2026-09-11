import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/tournament_model.dart';
import '../../core/services/tournament_service.dart';
import 'widgets/tournament_card.dart';

/// BR Matches & Tournaments Screen (Exact Alignment with Screenshot 2)
class TournamentsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const TournamentsScreen({super.key, this.onBack});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  @override
  void initState() {
    super.initState();
    TournamentService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: InkWell(
            onTap: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.maybePop(context);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.chevron_left_rounded, color: AppColors.textMain, size: 24),
              ),
            ),
          ),
        ),
        title: Text(
          'BR MATCHES & TOURNAMENTS',
          style: GoogleFonts.outfit(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textMain,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB), size: 22),
            onPressed: () => TournamentService.instance.refresh(),
            tooltip: 'Refresh Tournaments',
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: AppColors.borderLight),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => TournamentService.instance.refresh(),
        color: const Color(0xFF2563EB),
        backgroundColor: Colors.white,
        child: ValueListenableBuilder<List<TournamentModel>>(
          valueListenable: TournamentService.instance.tournamentsNotifier,
          builder: (context, tournaments, _) {
            if (tournaments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sports_esports_outlined, size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      Text(
                        'No Tournaments Scheduled',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'New Free Fire custom rooms will appear shortly.',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              itemCount: tournaments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final tourn = tournaments[index];
                return TournamentCard(
                  tournament: tourn,
                  onStateChanged: () => setState(() {}),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
