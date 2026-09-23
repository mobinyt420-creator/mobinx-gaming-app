import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PromoBannerModel {
  final String id;
  final String topText;
  final String title;
  final String subtitle;
  final String actionUrl;
  final String iconType; // 'telegram', 'gift', 'flash', 'star'

  PromoBannerModel({
    required this.id,
    required this.topText,
    required this.title,
    required this.subtitle,
    required this.actionUrl,
    required this.iconType,
  });

  factory PromoBannerModel.fromJson(Map<String, dynamic> json, String id) {
    return PromoBannerModel(
      id: id,
      topText: json['topText'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      actionUrl: json['actionUrl'] ?? '',
      iconType: json['iconType'] ?? 'star',
    );
  }
}

/// Promotional Mini Banners Grid (Dynamic 2-Column)
class PromoBannersGrid extends StatefulWidget {
  final VoidCallback onTelegramTap;
  final VoidCallback onSpecialOffersTap;

  const PromoBannersGrid({
    super.key,
    required this.onTelegramTap,
    required this.onSpecialOffersTap,
  });

  @override
  State<PromoBannersGrid> createState() => _PromoBannersGridState();
}

class _PromoBannersGridState extends State<PromoBannersGrid> {
  List<PromoBannerModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToBanners();
  }

  void _listenToBanners() {
    if (!FirebaseService.isInitialized) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    
    FirebaseService.firestore.doc('config/promo_banners').snapshots().listen((snap) {
      if (!mounted) return;
      if (snap.exists && snap.data() != null) {
        final data = snap.data()!;
        if (data['banners'] is List) {
          setState(() {
            _banners = (data['banners'] as List)
                .map((b) => PromoBannerModel.fromJson(Map<String, dynamic>.from(b), b['id'] ?? ''))
                .toList();
            _isLoading = false;
          });
          return;
        }
      }
      // Fallback to empty if not found or invalid format
      setState(() {
        _banners = [];
        _isLoading = false;
      });
    }, onError: (e) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _handleBannerTap(PromoBannerModel banner) async {
    if (banner.actionUrl == 'telegram') {
      widget.onTelegramTap();
    } else if (banner.actionUrl == 'offers' || banner.actionUrl == 'topup') {
      widget.onSpecialOffersTap();
    } else if (banner.actionUrl.startsWith('http')) {
      final uri = Uri.parse(banner.actionUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 80);
    }

    // Default banners if none exist in Firestore
    final List<PromoBannerModel> displayBanners = _banners.isNotEmpty ? _banners : [
      PromoBannerModel(
        id: 'default1',
        topText: 'JOIN OUR',
        title: 'TELEGRAM',
        subtitle: 'Get Latest Update First',
        actionUrl: 'telegram',
        iconType: 'telegram',
      ),
      PromoBannerModel(
        id: 'default2',
        topText: 'SPECIAL',
        title: 'OFFERS',
        subtitle: 'Don\'t Miss Out!',
        actionUrl: 'offers',
        iconType: 'gift',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2, // Approximates the height/width ratio
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: displayBanners.length,
        itemBuilder: (context, index) {
          final banner = displayBanners[index];
          return _buildBannerCard(banner);
        },
      ),
    );
  }

  Widget _buildBannerCard(PromoBannerModel banner) {
    Color topTextColor;
    List<Color> iconGradient;
    IconData iconData;
    Color iconColor;

    switch (banner.iconType) {
      case 'telegram':
        topTextColor = const Color(0xFF64748B);
        iconGradient = [const Color(0xFF0284C7), const Color(0xFF0369A1)];
        iconData = Icons.send_rounded;
        iconColor = Colors.white;
        break;
      case 'gift':
        topTextColor = const Color(0xFFD97706);
        iconGradient = [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)];
        iconData = Icons.card_giftcard;
        iconColor = const Color(0xFFF59E0B);
        break;
      case 'flash':
        topTextColor = const Color(0xFFE11D48);
        iconGradient = [const Color(0xFFFEE2E2), const Color(0xFFFECACA)];
        iconData = Icons.bolt_rounded;
        iconColor = const Color(0xFFEF4444);
        break;
      default:
        topTextColor = const Color(0xFF10B981);
        iconGradient = [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)];
        iconData = Icons.star_rounded;
        iconColor = const Color(0xFF059669);
    }

    return InkWell(
      onTap: () => _handleBannerTap(banner),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    banner.topText,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900, // Extra bold
                      color: topTextColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    banner.title,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    banner.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: iconGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
