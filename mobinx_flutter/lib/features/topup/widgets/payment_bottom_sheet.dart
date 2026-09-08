import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gamer_components.dart';
import '../../../core/models/diamond_package_model.dart';
import '../../../core/models/topup_request_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/topup_service.dart';

class PaymentBottomSheet extends StatefulWidget {
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

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final _playerIdController = TextEditingController();
  final _trxIdController = TextEditingController();
  
  String _selectedMethod = 'bKash';
  bool _isSubmitting = false;

  final String _bkashNumber = '01711223344'; // Mock Admin Number
  final String _nagadNumber = '01811223344';

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        backgroundColor: AppColors.cyanLight,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  Future<void> _submit() async {
    final playerId = _playerIdController.text.trim();
    final trxId = _trxIdController.text.trim();

    if (playerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your Player UID'), backgroundColor: AppColors.danger));
      return;
    }
    if (trxId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the TrxID'), backgroundColor: AppColors.danger));
      return;
    }

    setState(() => _isSubmitting = true);

    final user = AuthService.instance.currentUser;
    if (user == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    // Generate unique ID using Firestore
    final docId = FirebaseFirestore.instance.collection('topup_requests').doc().id;

    final request = TopUpRequestModel(
      id: docId,
      userId: user.uid,
      playerId: playerId,
      packageId: widget.package.id,
      paymentMethod: _selectedMethod,
      trxId: trxId,
      amount: widget.package.priceBDT,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final success = await TopupService.instance.submitTopUpRequest(request);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Top-Up Request Submitted!'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
        )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to submit request. Try again.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberToCopy = _selectedMethod == 'bKash' ? _bkashNumber : _nagadNumber;
    final isBkash = _selectedMethod == 'bKash';

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
            Text(
              'Checkout',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.package.name} • ৳${widget.package.priceBDT.toInt()}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.cyanLight,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Player ID Input
            Text(
              'PLAYER UID',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _playerIdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your game Player ID',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cyanLight),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Method
            Text(
              'PAYMENT METHOD',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 'bKash'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isBkash ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceCard,
                        border: Border.all(
                          color: isBkash ? AppColors.cyanLight : AppColors.borderLight,
                          width: isBkash ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'bKash',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: isBkash ? AppColors.cyanLight : AppColors.textMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 'Nagad'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isBkash ? AppColors.gold.withValues(alpha: 0.2) : AppColors.surfaceCard,
                        border: Border.all(
                          color: !isBkash ? AppColors.gold : AppColors.borderLight,
                          width: !isBkash ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Nagad',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: !isBkash ? AppColors.gold : AppColors.textMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Text(
                    'Send ৳${widget.package.priceBDT.toInt()} to the number below (Send Money):',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMain,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        numberToCopy,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.copy, color: AppColors.cyanLight, size: 20),
                        onPressed: () => _copyToClipboard(numberToCopy),
                        visualDensity: VisualDensity.compact,
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // TrxID Input
            Text(
              'TRANSACTION ID (TRXID)',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _trxIdController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter $_selectedMethod TrxID',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cyanLight),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            GamerButton(
              label: _isSubmitting ? 'PROCESSING...' : 'CONFIRM PAYMENT',
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
