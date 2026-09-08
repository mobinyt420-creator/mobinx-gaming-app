import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/banner_model.dart';
import '../../../core/services/store_service.dart';

class ShopProductItem {
  final String id;
  final String title;
  final String price;
  final String icon;
  final String tag;

  const ShopProductItem({
    required this.id,
    required this.title,
    required this.price,
    required this.icon,
    required this.tag,
  });
}

/// Flash Diamond Top Up & 2x2 Shop Products Section (Matching User's Audio Feedback)
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
  Timer? _countdownTimer;
  Timer? _autoScrollTimer;
  final ScrollController _diamondScrollController = ScrollController();
  bool _forward = true;

  static const List<ShopProductItem> _shopProducts = [
    ShopProductItem(
      id: 'shop-1',
      title: 'Weekly Pass',
      price: '৳ 165',
      icon: '🎫',
      tag: 'HOT',
    ),
    ShopProductItem(
      id: 'shop-2',
      title: 'Monthly Pass',
      price: '৳ 830',
      icon: '👑',
      tag: 'VIP',
    ),
    ShopProductItem(
      id: 'shop-3',
      title: 'Level Up Pass',
      price: '৳ 220',
      icon: '⚡',
      tag: 'BEST',
    ),
    ShopProductItem(
      id: 'shop-4',
      title: 'Evo Token Box',
      price: '৳ 95',
      icon: '📦',
      tag: 'NEW',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startDiamondAutoScroll();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _startDiamondAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_diamondScrollController.hasClients) return;
      final max = _diamondScrollController.position.maxScrollExtent;
      if (max <= 0) return;

      final current = _diamondScrollController.offset;
      double target;
      if (_forward) {
        target = current + 130;
        if (target >= max) {
          target = max;
          _forward = false;
        }
      } else {
        target = current - 130;
        if (target <= 0) {
          target = 0;
          _forward = true;
        }
      }

      _diamondScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoScrollTimer?.cancel();
    _diamondScrollController.dispose();
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
              price: '৳ 165',
              badge: 'BEST VALUE',
            ),
            FlashDealModel(
              id: 'flash-2',
              diamondAmount: '2000',
              price: 'Free Bonus',
              badge: 'HOT DEAL',
            ),
            FlashDealModel(
              id: 'flash-3',
              diamondAmount: 'Monthly',
              price: '৳ 830',
              badge: 'VIP',
            ),
            FlashDealModel(
              id: 'flash-4',
              diamondAmount: '520 Diamonds',
              price: '৳ 380',
              badge: 'POPULAR',
            ),
            FlashDealModel(
              id: 'flash-5',
              diamondAmount: '1060 Diamonds',
              price: '৳ 780',
              badge: 'MEGA',
            ),
          ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark Flash Countdown Header Banner (Image 1)
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

          // Horizontal Auto-Scrolling Diamond Cards
          SizedBox(
            height: 175,
            child: ListView.separated(
              controller: _diamondScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: displayDeals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final deal = displayDeals[index];
                final isOrangeBadge = deal.badge.toUpperCase().contains('BEST') ||
                    deal.badge.toUpperCase().contains('HOT') ||
                    index == 0;

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
                      // Badge
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
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMain,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            deal.price,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),

                      // Buy Button
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () => widget.onDealTap(deal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart, size: 11),
                              const SizedBox(width: 4),
                              Text(
                                'Buy Now',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
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
          const SizedBox(height: 14),

          // 2x2 Shop Products Section (Requested by User)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🛍️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    'VIP SHOP DEALS',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => StoreService.instance.openShop(),
                child: Text(
                  'Shop All ›',
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2x2 Compact Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _shopProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.6,
            ),
            itemBuilder: (context, index) {
              final product = _shopProducts[index];
              return InkWell(
                onTap: () => StoreService.instance.openShop(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(product.icon, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMain,
                              ),
                            ),
                            Text(
                              product.price,
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Buy',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
