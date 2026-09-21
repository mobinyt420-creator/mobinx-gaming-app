import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/download_item_model.dart';
import '../../../core/services/download_service.dart';
import '../../../core/services/admob_service.dart';

/// APK & Video Download Card with Full HD Thumbnail & In-App Player
class ToolCard extends StatefulWidget {
  final DownloadItemModel item;

  const ToolCard({super.key, required this.item});

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  String _getYoutubeId() {
    var raw = widget.item.youtubeId.trim();
    if (raw.contains('watch?v=')) {
      raw = raw.split('watch?v=')[1].split('&')[0];
    } else if (raw.contains('youtu.be/')) {
      raw = raw.split('youtu.be/')[1].split('?')[0];
    } else if (raw.contains('shorts/')) {
      raw = raw.split('shorts/')[1].split('?')[0];
    }
    return raw.isNotEmpty ? raw : 'dQw4w9WgXcQ';
  }

  void _openYouTubeApp(BuildContext context) {
    final yId = _getYoutubeId();
    DownloadService.instance.launchUrlString('https://www.youtube.com/watch?v=$yId');
  }

  void _handleVideoTap() {
    final yId = _getYoutubeId();
    // Safely open video directly in YouTube app or external player to avoid WebView OOM crash
    DownloadService.instance.launchUrlString('https://www.youtube.com/watch?v=$yId');
  }

  void _onDownloadButtonClick(BuildContext context, {required String label, required String targetUrl}) {
    if (!AdMobService.instance.isAdsEnabled) {
      DownloadService.instance.launchUrlString(targetUrl);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),

              // Animated Glowing Icon
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.lock_open_rounded, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                'ফাইলটি ডাউনলোড করতে আনলক করুন',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),

              // File badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.file_present_rounded, size: 14, color: Color(0xFF2563EB)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'একটি ছোট স্পনসর ভিডিও দেখুন (১৫-৩০ সেকেন্ড)। ভিডিও শেষ হওয়ার সাথে সাথে কোনো অতিরিক্ত লিংক শর্টনারের ঝামেলা ছাড়াই ডিরেক্ট ক্রোম ব্রাউজারে ডাউনলোড লিংক ওপেন হবে।',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.45,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Action Watch Video Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    AdMobService.instance.showRewardedAd(
                      context: context,
                      onRewardEarned: () {
                        DownloadService.instance.launchUrlString(targetUrl);
                      },
                      onCancelled: () {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'ভিডিওটি সম্পূর্ণ না দেখায় ফাইলটি আনলক হয়নি।',
                                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF0F172A),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'ভিডিও দেখুন ও ডাউনলোড করুন',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 38,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(
                    'বাতিল করুন',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 16:9 Video Player / Instant High-Res Thumbnail Preview
          AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: _handleVideoTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnail(item.videoThumbnail),

                  // Subtle gradient overlay for contrast
                  Container(
                    color: Colors.black.withValues(alpha: 0.15),
                  ),

                  // Compact Category Badge (Top Left)
                  if (item.category.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                  // Center Circular Blue Play Button with pulse feedback
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2563EB),
                        border: Border.all(color: Colors.white, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.5),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Body Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  item.title.isNotEmpty ? item.title : 'Mobin APK',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 12),

                // Action Button 1: Watch Video Tutorial (Exclusively opens YouTube App / Browser)
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () => _openYouTubeApp(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF2F2),
                      side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Watch Video Tutorial',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Action Buttons: Sleek, medium-sized, perfectly balanced
                if (item.actionButtons.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.actionButtons.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 3.6,
                    ),
                    itemBuilder: (context, idx) {
                      final btn = item.actionButtons[idx];
                      return SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () {
                            _onDownloadButtonClick(context, label: btn.label, targetUrl: btn.url);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFF6FF),
                            side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download_rounded, color: Color(0xFF2563EB), size: 16),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  btn.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        _onDownloadButtonClick(
                          context,
                          label: item.title.isNotEmpty ? item.title : 'Download File',
                          targetUrl: 'https://mrmobin.blogspot.com/',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF6FF),
                        side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download_rounded, color: Color(0xFF2563EB), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Pro APK Download',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// High Definition 16:9 Thumbnail (100% crisp with full YouTube maxres/sd fallback)
  Widget _buildThumbnail(String path) {
    final cleanPath = path.trim();
    final yId = _getYoutubeId();

    // If custom image thumbnail URL is provided directly, use it
    if (cleanPath.startsWith('http') && !cleanPath.contains('img.youtube.com') && !cleanPath.contains('i.ytimg.com')) {
      return CachedNetworkImage(
        imageUrl: cleanPath,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        placeholder: (_, _) => Container(color: const Color(0xFF0F172A)),
        errorWidget: (_, _, _) => _buildYouTubeThumbnail(yId),
      );
    }

    return _buildYouTubeThumbnail(yId);
  }

  Widget _buildYouTubeThumbnail(String yId) {
    return CachedNetworkImage(
      imageUrl: 'https://img.youtube.com/vi/$yId/hqdefault.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      placeholder: (_, _) => Container(color: const Color(0xFF0F172A)),
      errorWidget: (_, _, _) => CachedNetworkImage(
        imageUrl: 'https://img.youtube.com/vi/$yId/mqdefault.jpg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorWidget: (_, _, _) => Image.asset(
          'assets/images/banner_esports.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
