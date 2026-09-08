import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/tournament_model.dart';
import 'room_credentials_dialog.dart';
import 'match_registration_sheet.dart';

/// BR Match & Tournament Card (Exact Alignment with Screenshot 2)
class TournamentCard extends StatefulWidget {
  final TournamentModel tournament;
  final VoidCallback onStateChanged;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onStateChanged,
  });

  @override
  State<TournamentCard> createState() => _TournamentCardState();
}

class _TournamentCardState extends State<TournamentCard> {
  bool _showRoomDetails = false;
  bool _showPrizePool = false;
  int _countdownSeconds = 3597; // 00h 59m 57s
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatCountdown() {
    final hrs = (_countdownSeconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((_countdownSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (_countdownSeconds % 60).toString().padLeft(2, '0');
    return '${hrs}h ${mins}m ${secs}s';
  }

  String _formatStartsIn() {
    final hrs = (_countdownSeconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((_countdownSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (_countdownSeconds % 60).toString().padLeft(2, '0');
    return '${hrs}h:${mins}m:${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    final spotsLeft = (t.slotsTotal - t.slotsFilled).clamp(0, t.slotsTotal);
    final fillFraction = t.slotsTotal > 0 ? (t.slotsFilled / t.slotsTotal).clamp(0.0, 1.0) : 0.0;
    final isFull = t.slotsFilled >= t.slotsTotal;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (Image 2)
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Thumbnail with UPCOMING badge
                Stack(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF0F172A),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildThumb(t.banner),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Text(
                          t.status.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Title and Time Row
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title.isNotEmpty ? t.title : 'FF',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'TODAY at 08:30 PM',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⏳', style: TextStyle(fontSize: 10)),
                                const SizedBox(width: 3),
                                Text(
                                  _formatCountdown(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ],
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

          // 2. Details Grid (2 rows x 3 columns matching Image 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: [
                // Row 1: WIN PRIZE | GAME MODE | ENTRY FEE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCol(
                      'WIN PRIZE',
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.diamond, size: 14, color: Color(0xFF0284C7)),
                          const SizedBox(width: 3),
                          Text(
                            '500',
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatCol(
                      'GAME MODE',
                      Text(
                        t.mode.isNotEmpty ? t.mode : 'Solo BR',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    _buildStatCol(
                      'ENTRY FEE',
                      Text(
                        t.entryFee.isNotEmpty ? t.entryFee : 'Free',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 2: MAP | VERSION
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCol(
                        'MAP',
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🗺️', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              t.map.isNotEmpty ? t.map : 'Bermuda',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildStatCol(
                        'VERSION',
                        Text(
                          'MOBILE ONLY',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 3. Progress Bar & Spots Left & Join Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: fillFraction,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Only $spotsLeft spots left',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '${t.slotsFilled}/${t.slotsTotal}',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Join Button (Outlined Blue Pill)
                OutlinedButton(
                  onPressed: isFull
                      ? null
                      : () {
                          if (t.isRegistered && t.isRoomReleased) {
                            RoomCredentialsDialog.show(context, t);
                          } else {
                            MatchRegistrationSheet.show(
                              context,
                              t,
                              onRegistered: widget.onStateChanged,
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: t.isRegistered ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: Text(
                    t.isRegistered ? 'Joined' : 'Join',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: t.isRegistered ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 4. Dropdown Buttons: Room Details & Prize Pool
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _showRoomDetails = !_showRoomDetails),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📈', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            'Room Details',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _showRoomDetails ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _showPrizePool = !_showPrizePool),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            'Prize Pool',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _showPrizePool ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expandable Room Details content
          if (_showRoomDetails) ...[
            Container(
              margin: const EdgeInsets.only(left: 14, right: 14, top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room Rules & Instructions:',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    t.rules.isNotEmpty ? t.rules : 'Mobile only. No hack/script allowed. Room code released 15m before start.',
                    style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF475569)),
                  ),
                  if (t.isRegistered && t.isRoomReleased) ...[
                    const SizedBox(height: 6),
                    Text(
                      '🔑 Room ID: ${t.roomId} | Password: ${t.roomPassword}',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF10B981)),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Expandable Prize Pool content
          if (_showPrizePool) ...[
            Container(
              margin: const EdgeInsets.only(left: 14, right: 14, top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏆 1st Place: 💎 300 Diamonds',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0284C7)),
                  ),
                  Text(
                    '🥈 2nd Place: 💎 150 Diamonds',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                  ),
                  Text(
                    '🥉 3rd Place: 💎 50 Diamonds',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 5. Attached Green Bottom Countdown Bar (Image 2)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF059669),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time_filled, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'STARTS IN - ${_formatStartsIn()}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String title, Widget valueWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        valueWidget,
      ],
    );
  }

  Widget _buildThumb(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => Image.asset('assets/images/banner_esports.jpg', fit: BoxFit.cover),
      );
    }
    return Image.asset(
      path.isNotEmpty ? path : 'assets/images/banner_esports.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Image.asset('assets/images/banner_esports.jpg', fit: BoxFit.cover),
    );
  }
}
