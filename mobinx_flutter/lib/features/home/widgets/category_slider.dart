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
  static const double _itemWidth = 68.0;
  static const double _itemGap = 14.0;
  static const double _step = _itemWidth + _itemGap; // 82.0

  late final ScrollController _scrollController;
  Timer? _idleResumeTimer;
  Timer? _driftTimer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scheduleAutoDrift(const Duration(milliseconds: 800));
      }
    });
  }

  void _scheduleAutoDrift(Duration delay) {
    _idleResumeTimer?.cancel();
    _idleResumeTimer = Timer(delay, () {
      if (mounted && !_isInteracting) {
        _startSmoothDrift();
      }
    });
  }

  void _startSmoothDrift() {
    _driftTimer?.cancel();
    if (!mounted || !_scrollController.hasClients || _isInteracting) return;

    // Continuous linear glide: animates 60px every 1500ms (~40px/sec)
    _driftTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted || !_scrollController.hasClients || _isInteracting) {
        timer.cancel();
        return;
      }
      try {
        final currentOffset = _scrollController.offset;
        final cycleWidth = CategorySlider.categories.length * _step;
        if (currentOffset > cycleWidth * 100) {
          _scrollController.jumpTo(currentOffset % cycleWidth);
        }
        _scrollController.animateTo(
          _scrollController.offset + 60,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.linear,
        );
      } catch (_) {
        timer.cancel();
      }
    });
  }

  void _pauseDrift() {
    _isInteracting = true;
    _idleResumeTimer?.cancel();
    _driftTimer?.cancel();
  }

  void _resumeDriftAfterDelay() {
    _isInteracting = false;
    _scheduleAutoDrift(const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _isInteracting = true;
    _idleResumeTimer?.cancel();
    _driftTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      height: 92,
      child: Listener(
        onPointerDown: (_) => _pauseDrift(),
        onPointerUp: (_) => _resumeDriftAfterDelay(),
        onPointerCancel: (_) => _resumeDriftAfterDelay(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              _pauseDrift();
            } else if (notification is ScrollEndNotification) {
              _resumeDriftAfterDelay();
            }
            return false;
          },
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
                  onTap: () => widget.onCategoryTap(cat.route),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Press-to-scale category item with micro-interaction
class _PressableCategoryItem extends StatefulWidget {
  final QuickCategoryItem cat;
  final VoidCallback onTap;

  const _PressableCategoryItem({required this.cat, required this.onTap});

  @override
  State<_PressableCategoryItem> createState() => _PressableCategoryItemState();
}

class _PressableCategoryItemState extends State<_PressableCategoryItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: _CategorySliderState._itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Squircle Card with press feedback
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _isPressed
                      ? Color.lerp(widget.cat.bgColor, widget.cat.iconColor, 0.08)!
                      : widget.cat.bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.cat.iconColor.withValues(alpha: _isPressed ? 0.3 : 0.18),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.cat.iconColor.withValues(alpha: _isPressed ? 0.2 : 0.12),
                      blurRadius: _isPressed ? 4 : 8,
                      offset: Offset(0, _isPressed ? 1 : 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.cat.icon,
                    color: widget.cat.iconColor,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.cat.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
