import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'q': 'How do I join a custom BR room & tournament?',
      'a': 'Select any upcoming match from the Tournaments tab, tap "Join", and wait for the match schedule. The Room ID and password are released 15 minutes before the match directly in the app!',
      'open': false,
    },
    {
      'q': 'How fast is diamond top-up delivery?',
      'a': 'Diamond top-ups through NoobTopUp are processed instantly within 1 to 5 minutes via direct Player ID API integration.',
      'open': false,
    },
    {
      'q': 'What payment methods are supported in Bangladesh?',
      'a': 'bKash, Nagad, Rocket, Upay, and all major local debit/credit cards are fully supported with zero extra transaction fees.',
      'open': false,
    },
    {
      'q': 'Is the Sensitivity Maker 100% safe for Free Fire?',
      'a': 'Yes, 100% safe. Mobin X Sensitivity calculates safe native device DPI and internal in-game sensitivity sliders. It never injects or modifies game files, ensuring zero risk of ban.',
      'open': false,
    },
    {
      'q': 'How do I withdraw referral earnings?',
      'a': 'Once your referral balance reaches ৳200, you can request an instant withdrawal directly to your personal bKash or Nagad wallet from your Profile page.',
      'open': false,
    },
  ];

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support 24/7',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Online 24/7',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: AppColors.borderLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instant Contact Channels
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instant Contact Channels',
                    style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChannelCard(
                          icon: '💬',
                          title: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () => _launchUrl('https://wa.me/8801700000000'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChannelCard(
                          icon: '✈️',
                          title: 'Telegram',
                          color: const Color(0xFF0284C7),
                          onTap: () => _launchUrl(AppConstants.communityTelegram),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChannelCard(
                          icon: '🎫',
                          title: 'Live Ticket',
                          color: const Color(0xFF7C3AED),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening Support Ticket Engine...')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FAQs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _faqs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _faqs[index];
                      final isOpen = item['open'] == true;
                      return Container(
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.white : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isOpen ? AppColors.primary : AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() => item['open'] = !isOpen),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['q'],
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isOpen ? Icons.remove_rounded : Icons.add_rounded,
                                      size: 18,
                                      color: isOpen ? AppColors.primary : AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isOpen)
                              Padding(
                                padding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
                                child: Text(
                                  item['a'],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard({
    required String icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMain),
            ),
          ],
        ),
      ),
    );
  }
}
