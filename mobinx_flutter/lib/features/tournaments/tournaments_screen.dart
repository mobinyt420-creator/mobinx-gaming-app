import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/tournament_model.dart';
import '../../core/services/tournament_service.dart';
import '../../core/widgets/gamer_components.dart';
import 'widgets/tournament_card.dart';

/// Full Free Fire Esports Tournaments & Custom Rooms Arena
class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  String _statusFilter = 'ALL'; // ALL, UPCOMING, LIVE, MY_MATCHES, COMPLETED
  String _modeFilter = 'ALL'; // ALL, SQUAD, DUO, SOLO, CLASH SQUAD
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    TournamentService.instance.init();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TournamentModel> _applyFilters(List<TournamentModel> allTournaments) {
    return allTournaments.where((t) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchMap = t.map.toLowerCase().contains(q);
        final matchMode = t.mode.toLowerCase().contains(q);
        if (!matchTitle && !matchMap && !matchMode) return false;
      }

      // 2. Status Filter
      if (_statusFilter == 'UPCOMING' && t.status.toLowerCase() != 'upcoming') return false;
      if (_statusFilter == 'LIVE' && !t.isLive) return false;
      if (_statusFilter == 'COMPLETED' && t.status.toLowerCase() != 'completed') return false;
      if (_statusFilter == 'MY_MATCHES' && !t.isRegistered) return false;

      // 3. Mode Filter
      if (_modeFilter != 'ALL') {
        final m = t.mode.toLowerCase();
        if (_modeFilter == 'SQUAD' && !m.contains('squad')) return false;
        if (_modeFilter == 'DUO' && !m.contains('duo')) return false;
        if (_modeFilter == 'SOLO' && !m.contains('solo')) return false;
        if (_modeFilter == 'CLASH SQUAD' && !m.contains('clash')) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => TournamentService.instance.refresh(),
        color: AppColors.gold,
        backgroundColor: AppColors.surfaceCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Arena Esports Hero Banner
              _buildArenaHeader(),
              const SizedBox(height: 16),

              // 2. Search Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Search custom matches, maps, modes...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.cyanLight, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. Status Tabs (Pills)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildStatusPill('ALL', 'ALL MATCHES', Icons.grid_view_rounded),
                    const SizedBox(width: 8),
                    _buildStatusPill('UPCOMING', 'UPCOMING', Icons.schedule_rounded),
                    const SizedBox(width: 8),
                    _buildStatusPill('LIVE', '🔴 LIVE NOW', Icons.fiber_manual_record_rounded),
                    const SizedBox(width: 8),
                    _buildStatusPill('MY_MATCHES', 'MY MATCHES', Icons.check_circle_rounded),
                    const SizedBox(width: 8),
                    _buildStatusPill('COMPLETED', 'COMPLETED', Icons.flag_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 4. Mode Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildModeChip('ALL', 'ALL MODES'),
                    const SizedBox(width: 6),
                    _buildModeChip('SQUAD', 'SQUAD'),
                    const SizedBox(width: 6),
                    _buildModeChip('CLASH SQUAD', '4v4 CS'),
                    const SizedBox(width: 6),
                    _buildModeChip('DUO', 'DUO'),
                    const SizedBox(width: 6),
                    _buildModeChip('SOLO', 'SOLO HEADSHOT'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 5. Matches List
              ValueListenableBuilder<List<TournamentModel>>(
                valueListenable: TournamentService.instance.tournamentsNotifier,
                builder: (context, tournaments, _) {
                  final filtered = _applyFilters(tournaments);

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final tourn = filtered[index];
                      return TournamentCard(
                        tournament: tourn,
                        onStateChanged: () {
                          setState(() {});
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArenaHeader() {
    return GamerCard(
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.15),
          AppColors.primary.withValues(alpha: 0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: AppColors.gold.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESPORTS TOURNAMENT ARENA',
                    style: GoogleFonts.outfit(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Daily Custom Rooms with Instant bKash Payouts',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat('৳ 210,000+', 'PRIZES POOL', AppColors.gold),
              Container(width: 1, height: 28, color: AppColors.borderLight),
              _buildHeaderStat('100% FAIR', 'ANTI-CHEAT', AppColors.cyanLight),
              Container(width: 1, height: 28, color: AppColors.borderLight),
              _buildHeaderStat('15 MINS', 'ROOM RELEASE', AppColors.emerald),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String id, String label, IconData icon) {
    final isSelected = _statusFilter == id;
    return InkWell(
      onTap: () => setState(() => _statusFilter = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.cyanLight : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(String id, String label) {
    final isSelected = _modeFilter == id;
    return InkWell(
      onTap: () => setState(() => _modeFilter = id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyanLight.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.cyanLight : AppColors.borderLight,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.cyanLight : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.sports_esports_outlined, size: 54, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No Matches Found',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your filters or searching another keyword.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _statusFilter = 'ALL';
                  _modeFilter = 'ALL';
                  _searchQuery = '';
                  _searchCtrl.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyanLight,
                side: const BorderSide(color: AppColors.cyanLight),
              ),
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
