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

class _CategorySliderState extends State<CategorySlider> with SingleTickerProviderStateMixin {
  static const double _itemWidth = 70.0;
  static const double _itemGap = 12.0;
  static const double _step = _itemWidth + _itemGap;

  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  bool _isUserTouching = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Start at a balanced middle index so users can scroll both left and right smoothly
    const initialIndex = 50 * 7;
    _scrollController = ScrollController(initialScrollOffset: initialIndex * _step);

    // Subtle breathing micro-animation controller for icons
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGentleAutoScroll();
    });
  }

  void _startGentleAutoScroll() {
    _autoScrollTimer?.cancel();
    // Gentle step glide every 2.6 seconds (smooth 850ms transition + ~1.75s pause)
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (!mounted || !_scrollController.hasClients || _isUserTouching) return;

      try {
        final currentOffset = _scrollController.offset;
        final double loopWidth = CategorySlider.categories.length * _step;

        // Reset if scrolled extremely far to keep offsets within normal double ranges
        if (currentOffset > loopWidth * 60) {
          final normalized = currentOffset % loopWidth + (loopWidth * 20);
          _scrollController.jumpTo(normalized);
        }

        _scrollController.animateTo(
          _scrollController.offset + _step,
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeInOutCubic,
        );
      } catch (_) {}
    });
  }

  void _onUserInteractionStart() {
    _isUserTouching = true;
    _resumeTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _isUserTouching = false;
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      height: 98,
      child: Listener(
        onPointerDown: (_) => _onUserInteractionStart(),
        onPointerUp: (_) => _onUserInteractionEnd(),
        onPointerCancel: (_) => _onUserInteractionEnd(),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: 10000,
          itemBuilder: (context, index) {
            final cat = CategorySlider.categories[index % CategorySlider.categories.length];
            return Padding(
              padding: const EdgeInsets.only(right: _itemGap),
              child: _PressableCategoryItem(
                cat: cat,
                pulseAnimation: _pulseController,
                itemIndex: index % CategorySlider.categories.length,
                onTap: () => widget.onCategoryTap(cat.route),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Press-to-scale category item with glossy squircle feedback & subtle breathing micro-animation
class _PressableCategoryItem extends StatefulWidget {
  final QuickCategoryItem cat;
  final Animation<double> pulseAnimation;
  final int itemIndex;
  final VoidCallback onTap;

  const _PressableCategoryItem({
    required this.cat,
    required this.pulseAnimation,
    required this.itemIndex,
    required this.onTap,
  });

  @override
  State<_PressableCategoryItem> createState() => _PressableCategoryItemState();
}

class _PressableCategoryItemState extends State<_PressableCategoryItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Staggered micro-pulsing for organic, professional visual flow
    final isStaggered = widget.itemIndex % 2 == 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: _CategorySliderState._itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Squircle Card with subtle live micro-animation
              AnimatedBuilder(
                animation: widget.pulseAnimation,
                builder: (context, child) {
                  final pulseVal = widget.pulseAnimation.value;
                  final subtleGlow = isStaggered ? pulseVal * 0.12 : (1.0 - pulseVal) * 0.12;

                  return Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.cat.bgColor,
                          Color.lerp(widget.cat.bgColor, Colors.white, 0.45)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: widget.cat.iconColor.withValues(alpha: 0.25 + subtleGlow),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.cat.iconColor.withValues(alpha: 0.15 + subtleGlow),
                          blurRadius: 10 + (subtleGlow * 20),
                          offset: const Offset(0, 4),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 4,
                          offset: Offset(-1, -1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: 1.0 + (subtleGlow * 0.25),
                        child: Icon(
                          widget.cat.icon,
                          color: widget.cat.iconColor,
                          size: 28,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                widget.cat.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                  letterSpacing: -0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
