import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/banner_model.dart';
import '../../../core/services/store_service.dart';
import '../../../core/services/firebase_service.dart';

class EcommerceProductItem {
  final String id;
  final String title;
  final String category; // 'Clothing' or 'Gadget'
  final String price;
  final String originalPrice;
  final String imageUrl;
  final String tag;

  const EcommerceProductItem({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.tag,
  });

  factory EcommerceProductItem.fromJson(Map<String, dynamic> json) {
    return EcommerceProductItem(
      id: json['id']?.toString() ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Gaming Product',
      category: json['category']?.toString() ?? 'Merchandise',
      price: json['price']?.toString() ?? '৳ 650',
      originalPrice: json['originalPrice']?.toString() ?? '৳ 850',
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString() ?? '',
      tag: json['tag']?.toString() ?? json['badge']?.toString() ?? 'HOT',
    );
  }
}

/// Flash Diamond Top Up & 2 E-Commerce Products Section (Exact User Specifications)
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
  int _remainingSeconds = 2 * 3600 + 35 * 60 + 28; // 02:35:28
  Timer? _countdownTimer;
  Timer? _autoScrollTimer;
  late final ScrollController _diamondScrollController;

  static const double _diamondCardWidth = 124.0;
  static const double _diamondCardGap = 10.0;
  static const double _diamondStep = _diamondCardWidth + _diamondCardGap; // 134.0

  List<EcommerceProductItem> _ecommerceProducts = [
    const EcommerceProductItem(
      id: 'ecom-1',
      title: 'Mobin X Pro Esports Jersey',
      category: 'Official T-Shirt',
      price: '৳ 650',
      originalPrice: '৳ 850',
      imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=500&q=80',
      tag: 'BESTSELLER',
    ),
    const EcommerceProductItem(
      id: 'ecom-2',
      title: 'Mobin X RGB Gaming Headset',
      category: 'Pro Audio Gadget',
      price: '৳ 1,250',
      originalPrice: '৳ 1,600',
      imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500&q=80',
      tag: 'TOP GADGET',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start at a multiple of diamonds so it loops seamlessly in one direction
    const initialIndex = 500 * 5;
    _diamondScrollController = ScrollController(initialScrollOffset: initialIndex * _diamondStep);

    _startCountdown();
    _startDiamondAutoScroll();
    _listenToShopProducts();
  }

  void _listenToShopProducts() {
    if (FirebaseService.isInitialized) {
      try {
        FirebaseService.firestore.collection('shop_products').limit(2).snapshots().listen((snap) {
          if (snap.docs.isNotEmpty) {
            final live = snap.docs
                .map((doc) => EcommerceProductItem.fromJson({...doc.data(), 'id': doc.id}))
                .toList();
            if (live.isNotEmpty && mounted) {
              setState(() {
                _ecommerceProducts = live.take(2).toList();
              });
            }
          }
        });
      } catch (_) {}
    }
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
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (!mounted || !_diamondScrollController.hasClients) return;
      _diamondScrollController.animateTo(
        _diamondScrollController.offset + _diamondStep,
        duration: const Duration(milliseconds: 1400),
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
              price: '৳ 00',
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
              diamondAmount: '100 DIAMONDS',
              price: '৳ 380',
              badge: 'HOT',
            ),
            FlashDealModel(
              id: 'flash-4',
              diamondAmount: 'Monthly',
              price: '৳ 830',
              badge: 'POPULAR',
            ),
            FlashDealModel(
              id: 'flash-5',
              diamondAmount: '520 DIAMONDS',
              price: '৳ 380',
              badge: '100% BONUS',
            ),
          ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flash Diamond Header with Vibrant Red Timer Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
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
                // Vibrant Red Gradient Countdown Timer Badge (User Requested Red)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFFEF08A),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Ends\nIn',
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white70,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTimerSingleLine(),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Infinite Forward Looping Diamond Cards (Never reverses)
          SizedBox(
            height: 175,
            child: ListView.builder(
              controller: _diamondScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 100000,
              itemBuilder: (context, index) {
                final deal = displayDeals[index % displayDeals.length];
                final isOrangeBadge = deal.badge.toUpperCase().contains('BEST') ||
                    deal.badge.toUpperCase().contains('HOT') ||
                    index % displayDeals.length == 0;

                return Padding(
                  padding: const EdgeInsets.only(right: _diamondCardGap),
                  child: Container(
                    width: _diamondCardWidth,
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
                            Icons.diamond_rounded,
                            size: 42,
                            color: Color(0xFF0284C7),
                          ),
                        ),

                        // Diamond Amount
                        Text(
                          deal.diamondAmount,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                          ),
                        ),

                        // Price
                        Text(
                          deal.price,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0284C7),
                          ),
                        ),

                        // Buy Now Button
                        SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: ElevatedButton(
                            onPressed: () => widget.onDealTap(deal),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // 2 E-Commerce Products Section (User Requested Exactly 2 Side-by-Side Cards)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('👕', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text(
                    'OFFICIAL SHOP DEALS',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Exactly 2 Side-by-Side E-Commerce Products (Clothing & Gadget)
          Row(
            children: [
              Expanded(
                child: _buildEcommerceProductCard(_ecommerceProducts[0]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildEcommerceProductCard(_ecommerceProducts.length > 1
                    ? _ecommerceProducts[1]
                    : _ecommerceProducts[0]),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildEcommerceProductCard(EcommerceProductItem product) {
    return InkWell(
      onTap: () => StoreService.instance.openShop(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Discount Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: product.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: Icon(Icons.shopping_bag_outlined, color: Colors.black26),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFFFF7ED),
                              child: const Center(
                                child: Icon(Icons.local_mall_rounded, color: Color(0xFFEA580C), size: 36),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFFFF7ED),
                            child: const Center(
                              child: Icon(Icons.local_mall_rounded, color: Color(0xFFEA580C), size: 36),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      product.tag,
                      style: GoogleFonts.outfit(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.price,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFEA580C),
                            ),
                          ),
                          Text(
                            product.originalPrice,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: Colors.white, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              'Buy',
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
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
    );
  }
}
