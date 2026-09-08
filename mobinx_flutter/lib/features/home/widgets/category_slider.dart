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

/// Quick 4-Category Shortcuts (Exact Alignment with Screenshot 1)
class CategorySlider extends StatelessWidget {
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
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((cat) {
          return InkWell(
            onTap: () => onCategoryTap(cat.route),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: cat.bgColor,
                      shape: BoxShape.circle,
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
                  const SizedBox(height: 6),
                  Text(
                    cat.title,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
