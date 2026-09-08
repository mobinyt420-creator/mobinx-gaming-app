import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class QuickCategoryItem {
  final String id;
  final String title;
  final String route;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const QuickCategoryItem({
    required this.id,
    required this.title,
    required this.route,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

/// Squircle Shaped Animated Category Slider (Matching User's Specs)
class CategorySlider extends StatefulWidget {
  final Function(String route) onCategoryTap;

  const CategorySlider({
    super.key,
    required this.onCategoryTap,
  });

  static const List<QuickCategoryItem> categories = [
    QuickCategoryItem(
      id: 'downloads',
      title: 'Downloads',
      route: 'downloads',
      icon: Icons.file_download_outlined,
      bgColor: Color(0xFFDCFCE7),
      iconColor: Color(0xFF16A34A),
    ),
    QuickCategoryItem(
      id: 'tournaments',
      title: 'Tournaments',
      route: 'tournaments',
      icon: Icons.emoji_events_outlined,
      bgColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
    ),
    QuickCategoryItem(
      id: 'topup',
      title: 'Top Up',
      route: 'topup',
      icon: Icons.diamond_outlined,
      bgColor: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
    ),
    QuickCategoryItem(
      id: 'shop',
      title: 'Shop',
      route: 'shop',
      icon: Icons.shopping_bag_outlined,
      bgColor: Color(0xFFF3E8FF),
      iconColor: Color(0xFF9333EA),
    ),
    QuickCategoryItem(
      id: 'sensitivity',
      title: 'Sensitivity',
      route: 'sensitivity',
      icon: Icons.tune_rounded,
      bgColor: Color(0xFFEFF6FF),
      iconColor: Color(0xFF2563EB),
    ),
    QuickCategoryItem(
      id: 'referral',
      title: 'Refer & Earn',
      route: 'referral',
      icon: Icons.card_giftcard_rounded,
      bgColor: Color(0xFFFDF2F8),
      iconColor: Color(0xFFDB2777),
    ),
    QuickCategoryItem(
      id: 'telegram',
      title: 'Community',
      route: 'telegram',
      icon: Icons.send_rounded,
      bgColor: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
    ),
  ];

  @override
  State<CategorySlider> createState() => _CategorySliderState();
}

class _CategorySliderState extends State<CategorySlider> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (max <= 0) return;

      final current = _scrollController.offset;
      double target;
      if (_forward) {
        target = current + 150;
        if (target >= max) {
          target = max;
          _forward = false;
        }
      } else {
        target = current - 150;
        if (target <= 0) {
          target = 0;
          _forward = true;
        }
      }

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      height: 90,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: CategorySlider.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = CategorySlider.categories[index];
          return InkWell(
            onTap: () => widget.onCategoryTap(cat.route),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Squircle Card
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: cat.bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cat.iconColor.withValues(alpha: 0.18),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cat.iconColor.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        cat.icon,
                        color: cat.iconColor,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cat.title,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
