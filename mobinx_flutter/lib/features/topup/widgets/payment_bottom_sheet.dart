import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gamer_components.dart';
import '../../../core/models/diamond_package_model.dart';
import '../../../core/constants/app_constants.dart';

class PaymentBottomSheet extends StatelessWidget {
  final DiamondPackageModel package;

  const PaymentBottomSheet({super.key, required this.package});

  static Future<void> show(BuildContext context, DiamondPackageModel package) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentBottomSheet(package: package),
    );
  }

  Future<void> _launchPartnerUrl(BuildContext context) async {
    Navigator.pop(context);
    final uri = Uri.parse(AppConstants.topUpPartnerUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[PaymentBottomSheet] Launch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Header icon
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.cyanLight.withValues(alpha: 0.4)),
                ),
                child: const Center(
                  child: Text('💎', style: TextStyle(fontSize: 28)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'Official Web Partner Portal',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${package.diamonds} Diamonds • ৳${package.priceBDT.toInt()}',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.cyanLight,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Partner Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Partner: NoobTopUp.com',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Instant 24/7 automated delivery via Player UID',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 14),
                  _buildBenefitRow(Icons.bolt_rounded, 'Instant direct delivery into your game account'),
                  const SizedBox(height: 8),
                  _buildBenefitRow(Icons.lock_outline_rounded, '100% Safe, encrypted & verified web checkout'),
                  const SizedBox(height: 8),
                  _buildBenefitRow(Icons.support_agent_rounded, '24/7 dedicated gamer live support'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Continue Button
            GamerButton(
              label: 'CONTINUE TO OFFICIAL WEBSITE',
              onPressed: () => _launchPartnerUrl(context),
            ),
            const SizedBox(height: 12),

            // Compliance Footnote
            Text(
              'Orders and deliveries are fulfilled securely on our official partner web portal in your external browser.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.cyanLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMain,
            ),
          ),
        ),
      ],
    );
  }
}

