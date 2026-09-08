import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

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
}

/// Popular Services Grid (Exact 2x3 Grid Matching Screenshot 1)
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
          // Section Header Row (Image 1)
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

          // 2x3 Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: defaultServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final item = defaultServices[index];
              return InkWell(
                onTap: () => onServiceTap(item.route),
                borderRadius: BorderRadius.circular(16),
                child: Container(
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
                            child: Image.asset(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(Icons.videogame_asset, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Label Container (Image 1)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: Text(
                          item.title,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
