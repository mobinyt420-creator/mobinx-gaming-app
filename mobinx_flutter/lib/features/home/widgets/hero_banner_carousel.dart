import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/banner_model.dart';

/// Clean 16:9 Auto-scrolling Hero Banner Carousel (Exact match with user specs: no dark overlay, no text/explore button, no blue borders)
class HeroBannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  final Function(BannerModel banner) onBannerTap;

  const HeroBannerCarousel({
    super.key,
    required this.banners,
    required this.onBannerTap,
  });

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || widget.banners.isEmpty) return;
      final nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) {
              setState(() => _currentPage = idx);
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return AnimatedScale(
                scale: _currentPage == index ? 1.0 : 0.96,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () => widget.onBannerTap(banner),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildBannerImage(banner.image),
                  ),
                ),
              );
            },
          ),
        ),

        // Indicator Dots
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (idx) {
              final isSel = _currentPage == idx;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSel ? 16 : 6,
                height: 5,
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildBannerImage(String path) {
    final cleanPath = path.trim();
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: cleanPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: const Color(0xFF1E293B),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/banner_booyah.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    return Image.asset(
      cleanPath.isNotEmpty ? cleanPath : 'assets/images/banner_booyah.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF1E293B),
        child: const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.white38, size: 40),
        ),
      ),
    );
  }
}
