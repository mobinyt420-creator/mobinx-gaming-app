import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/tournament_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/tournament_service.dart';
import '../../../core/widgets/gamer_components.dart';

/// Interactive Tournament Registration Bottom Sheet
class MatchRegistrationSheet extends StatefulWidget {
  final TournamentModel tournament;
  final VoidCallback onRegistered;

  const MatchRegistrationSheet({
    super.key,
    required this.tournament,
    required this.onRegistered,
  });

  static void show(BuildContext context, TournamentModel tournament, {required VoidCallback onRegistered}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MatchRegistrationSheet(
        tournament: tournament,
        onRegistered: onRegistered,
      ),
    );
  }

  @override
  State<MatchRegistrationSheet> createState() => _MatchRegistrationSheetState();
}

class _MatchRegistrationSheetState extends State<MatchRegistrationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ignCtrl;
  late final TextEditingController _ffUidCtrl;
  late final TextEditingController _phoneCtrl;

  // Teammates controllers
  final TextEditingController _tm2Ign = TextEditingController();
  final TextEditingController _tm2Uid = TextEditingController();
  final TextEditingController _tm3Ign = TextEditingController();
  final TextEditingController _tm3Uid = TextEditingController();
  final TextEditingController _tm4Ign = TextEditingController();
  final TextEditingController _tm4Uid = TextEditingController();

  bool _agreedRules = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    // Do NOT auto-fill IGN so users enter their real Free Fire Game ID Name
    _ignCtrl = TextEditingController();
    _ffUidCtrl = TextEditingController(text: user?.ffUid.isNotEmpty == true ? user!.ffUid : '');
    _phoneCtrl = TextEditingController(text: user?.phone.isNotEmpty == true ? user!.phone : '');
  }

  @override
  void dispose() {
    _ignCtrl.dispose();
    _ffUidCtrl.dispose();
    _phoneCtrl.dispose();
    _tm2Ign.dispose();
    _tm2Uid.dispose();
    _tm3Ign.dispose();
    _tm3Uid.dispose();
    _tm4Ign.dispose();
    _tm4Uid.dispose();
    super.dispose();
  }

  bool get _isTeamMode {
    final m = widget.tournament.mode.toLowerCase();
    return m.contains('squad') || m.contains('duo');
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedRules) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please agree to the match fair-play rules.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final teammates = <Map<String, String>>[];
    if (_tm2Ign.text.trim().isNotEmpty) {
      teammates.add({'ign': _tm2Ign.text.trim(), 'ffUid': _tm2Uid.text.trim()});
    }
    if (_tm3Ign.text.trim().isNotEmpty) {
      teammates.add({'ign': _tm3Ign.text.trim(), 'ffUid': _tm3Uid.text.trim()});
    }
    if (_tm4Ign.text.trim().isNotEmpty) {
      teammates.add({'ign': _tm4Ign.text.trim(), 'ffUid': _tm4Uid.text.trim()});
    }

    final success = await TournamentService.instance.registerPlayer(
      tournament: widget.tournament,
      ign: _ignCtrl.text.trim(),
      ffUid: _ffUidCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      teammates: teammates,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      widget.onRegistered();

      // Show Success Dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.emerald, width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 28),
              const SizedBox(width: 10),
              Text(
                'Registered Successfully!',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: Text(
            'You are officially locked in for "${widget.tournament.title}".\n\nRoom ID & Password will be released 15 minutes before match start.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textBody,
              height: 1.45,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('AWESOME, READY 🎮'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Header: Title & Close
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.gamerGlowGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.app_registration_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOURNAMENT REGISTRATION',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.tournament.title,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tournament Summary Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('MODE', widget.tournament.mode, const Color(0xFF2563EB)),
                  _buildSummaryItem('ENTRY', widget.tournament.entryFee, const Color(0xFF10B981)),
                  _buildSummaryItem('PRIZE POOL', widget.tournament.prizePool, const Color(0xFFD97706)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Form Inputs
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Captain / Player 1 IGN
                    _buildFieldLabel('Game ID Name (In-Game Name) *'),
                    TextFormField(
                      controller: _ignCtrl,
                      style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'Enter your Free Fire In-Game Name',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.badge_rounded, size: 20, color: Color(0xFF2563EB)),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Game ID Name is required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Free Fire UID
                    _buildFieldLabel('Free Fire UID (10 Digits) *'),
                    TextFormField(
                      controller: _ffUidCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'e.g. 1928374650',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.pin_rounded, size: 20, color: Color(0xFFD97706)),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Free Fire UID is required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Phone / bKash Number
                    _buildFieldLabel('bKash / Nagad Number (For Prize Delivery) *'),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: '01XXXXXXXXX',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20, color: Color(0xFF10B981)),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Phone number is required' : null,
                    ),

                    // Team mode members (Squad / Duo)
                    if (_isTeamMode) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Icon(Icons.group_rounded, size: 16, color: AppColors.cyanLight),
                          const SizedBox(width: 6),
                          Text(
                            'TEAM MEMBERS (OPTIONAL / SUB-MEMBERS)',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cyanLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Player 2
                      _buildTeammateRow('Player 2', _tm2Ign, _tm2Uid),
                      const SizedBox(height: 8),

                      // Player 3
                      _buildTeammateRow('Player 3', _tm3Ign, _tm3Uid),
                      const SizedBox(height: 8),

                      // Player 4
                      _buildTeammateRow('Player 4', _tm4Ign, _tm4Uid),
                    ],

                    const SizedBox(height: 16),

                    // Rules Agreement Checkbox
                    GestureDetector(
                      onTap: () => setState(() => _agreedRules = !_agreedRules),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _agreedRules,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              side: const BorderSide(color: AppColors.textMuted, width: 1.5),
                              onChanged: (val) => setState(() => _agreedRules = val ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'I agree to fair play rules (No hacks, no teaming, only mobile devices).',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: AppColors.textBody,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Submit Button
            GamerButton(
              label: 'CONFIRM REGISTRATION ⚡',
              isLoading: _isSubmitting,
              onPressed: _handleSubmit,
              height: 46,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String val, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w800, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }

  Widget _buildTeammateRow(String label, TextEditingController ignCtrl, TextEditingController uidCtrl) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ignCtrl,
              style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '$label IGN',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: uidCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '$label UID',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
