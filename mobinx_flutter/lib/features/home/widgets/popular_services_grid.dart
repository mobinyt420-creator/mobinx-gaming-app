import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/home_data_service.dart';

class PopularServiceItem {
  final String id;
  final String title;
  final String image;
  final String route;

  const PopularServiceItem({
    required this.id,
    required this.title,
    required this.image,
    required this.route,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image': image,
    'route': route,
  };

  factory PopularServiceItem.fromJson(Map<String, dynamic> json) {
    return PopularServiceItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
    );
  }

  PopularServiceItem copyWith({
    String? id,
    String? title,
    String? image,
    String? route,
  }) {
    return PopularServiceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      route: route ?? this.route,
    );
  }
}

/// Popular Services Grid (2x3 Grid with real-time Admin Customization & Offline Fallback)
class PopularServicesGrid extends StatelessWidget {
  final Function(String route) onServiceTap;
  final VoidCallback? onViewAllTap;

  const PopularServicesGrid({
    super.key,
    required this.onServiceTap,
    this.onViewAllTap,
  });

  static const List<PopularServiceItem> defaultServices = [
    PopularServiceItem(
      id: 'topup',
      title: 'TOP UP',
      image: 'assets/images/service_topup.jpg',
      route: 'topup',
    ),
    PopularServiceItem(
      id: 'shop',
      title: 'SHOP',
      image: 'assets/images/service_shop.jpg',
      route: 'shop',
    ),
    PopularServiceItem(
      id: 'downloads',
      title: 'DOWNLOADS',
      image: 'assets/images/service_downloads.jpg',
      route: 'downloads',
    ),
    PopularServiceItem(
      id: 'tournaments',
      title: 'TOURNAMENTS',
      image: 'assets/images/service_tournaments.jpg',
      route: 'tournaments',
    ),
    PopularServiceItem(
      id: 'sensitivity',
      title: 'SENSITIVITY MAKER',
      image: 'assets/images/service_sensitivity.jpg',
      route: 'sensitivity',
    ),
    PopularServiceItem(
      id: 'profile',
      title: 'PROFILE',
      image: 'assets/images/service_profile.jpg',
      route: 'profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'Popular Services & Products',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              if (onViewAllTap != null)
                GestureDetector(
                  onTap: onViewAllTap,
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Dynamic 2x3 Grid from HomeDataService
          ValueListenableBuilder<List<PopularServiceItem>>(
            valueListenable: HomeDataService.instance.servicesNotifier,
            builder: (context, services, _) {
              final activeList = services.isNotEmpty ? services : defaultServices;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final item = activeList[index];
                  return _PressableServiceCard(
                    item: item,
                    onTap: () => onServiceTap(item.route),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Press-to-scale animated service card with network / asset image support
class _PressableServiceCard extends StatefulWidget {
  final PopularServiceItem item;
  final VoidCallback onTap;

  const _PressableServiceCard({required this.item, required this.onTap});

  @override
  State<_PressableServiceCard> createState() => _PressableServiceCardState();
}

class _PressableServiceCardState extends State<_PressableServiceCard> {
  bool _isPressed = false;

  Widget _buildImageWidget(String path) {
    if (path.startsWith('data:image')) {
      try {
        final commaIdx = path.indexOf(',');
        if (commaIdx != -1) {
          final bytes = base64Decode(path.substring(commaIdx + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _fallbackAsset(),
          );
        }
      } catch (_) {}
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          color: const Color(0xFFE2E8F0),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
            ),
          ),
        ),
        errorWidget: (_, _, _) => _fallbackAsset(),
      );
    }
    return Image.asset(
      path.isNotEmpty ? path : 'assets/images/service_topup.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallbackAsset(),
    );
  }

  Widget _fallbackAsset() {
    // Match ID to local asset
    String defaultAsset = 'assets/images/service_topup.jpg';
    switch (widget.item.id) {
      case 'shop':
        defaultAsset = 'assets/images/service_shop.jpg';
        break;
      case 'downloads':
        defaultAsset = 'assets/images/service_downloads.jpg';
        break;
      case 'tournaments':
        defaultAsset = 'assets/images/service_tournaments.jpg';
        break;
      case 'sensitivity':
        defaultAsset = 'assets/images/service_sensitivity.jpg';
        break;
      case 'profile':
        defaultAsset = 'assets/images/service_profile.jpg';
        break;
    }
    return Image.asset(defaultAsset, fit: BoxFit.cover);
  }

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
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.08 : 0.04),
                blurRadius: _isPressed ? 4 : 8,
                offset: Offset(0, _isPressed ? 1 : 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 1:1 Aspect Ratio Image Box
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImageWidget(widget.item.image),
                  ),
                ),
              ),

              // Label Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                color: Colors.white,
                alignment: Alignment.center,
                child: Text(
                  widget.item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
