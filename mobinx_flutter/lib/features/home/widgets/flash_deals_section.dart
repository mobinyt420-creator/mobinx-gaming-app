import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/banner_model.dart';

/// Flash Diamond Top Up Section (Exact Alignment with Screenshot 1)
class FlashDealsSection extends StatefulWidget {
  final List<FlashDealModel> deals;
  final Function(FlashDealModel deal) onDealTap;
  final VoidCallback onViewAllTap;

  const FlashDealsSection({
    super.key,
    required this.deals,
    required this.onDealTap,
    required this.onViewAllTap,
  });

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
  int _remainingSeconds = 2 * 3600 + 35 * 60 + 34; // 02:35:34
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimerSingleLine() {
    final hrs = (_remainingSeconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((_remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$hrs : $mins : $secs';
  }

  @override
  Widget build(BuildContext context) {
    final displayDeals = widget.deals.isNotEmpty
        ? widget.deals
        : [
            FlashDealModel(
              id: 'flash-1',
              diamondAmount: 'Weekly',
              price: '৳00',
              badge: 'BEST VALUE',
            ),
            FlashDealModel(
              id: 'flash-2',
              diamondAmount: '2000',
              price: 'Free',
              badge: 'VIP',
            ),
            FlashDealModel(
              id: 'flash-3',
              diamondAmount: 'Monthly Topup',
              price: '৳380',
              badge: '',
            ),
          ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark Header Banner (Image 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1427),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Flash Title
                Row(
                  children: [
                    const Icon(
                      Icons.bolt,
                      color: Color(0xFFFBBF24),
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'FLASH ',
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFBBF24),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'DIAMOND TOP\nUP',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),

                // Right Countdown Pill (Image 1: Clock Icon + Ends In + 02 : 35 : 34)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        color: Colors.white70,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ends\nIn',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF93C5FD),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTimerSingleLine(),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
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
          ),
          const SizedBox(height: 10),

          // Horizontal Product Cards (Image 1)
          SizedBox(
            height: 175,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayDeals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final deal = displayDeals[index];
                final isOrangeBadge = deal.badge.toUpperCase().contains('BEST') || index == 0;

                return Container(
                  width: 122,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge row at top
                      if (deal.badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOrangeBadge ? const Color(0xFFEA580C) : const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            deal.badge,
                            style: GoogleFonts.outfit(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 14),

                      // Diamond Graphic
                      const Center(
                        child: Icon(
                          Icons.diamond,
                          color: Color(0xFF0284C7),
                          size: 36,
                        ),
                      ),

                      // Amount & Price
                      Column(
                        children: [
                          Text(
                            deal.diamondAmount,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            deal.price,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),

                      // Buy Now Gradient Button
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () => widget.onDealTap(deal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEAB308),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'Buy Now',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
