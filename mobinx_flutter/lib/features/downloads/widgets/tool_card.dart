import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/download_item_model.dart';
import '../../../core/services/download_service.dart';

/// APK & Video Download Card with Full HD Thumbnail & In-App Player
class ToolCard extends StatefulWidget {
  final DownloadItemModel item;

  const ToolCard({super.key, required this.item});

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _isPlaying = false;
  YoutubePlayerController? _ytController;

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

  void _startInAppVideo() {
    final yId = _getYoutubeId();
    _ytController?.close();
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: yId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        showVideoAnnotations: false,
      ),
    );
    setState(() {
      _isPlaying = true;
    });
  }

  void _stopInAppVideo() {
    _ytController?.close();
    _ytController = null;
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _ytController?.close();
    super.dispose();
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
          // 1. 16:9 Video Player / Thumbnail Preview
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isPlaying && _ytController != null
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: YoutubePlayer(
                          controller: _ytController!,
                          aspectRatio: 16 / 9,
                        ),
                      ),
                      // Stop / Close player button (returns to HD thumbnail)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: _stopInAppVideo,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white38),
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: _startInAppVideo,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildThumbnail(item.videoThumbnail),

                        // Subtle gradient overlay for contrast
                        Container(
                          color: Colors.black.withValues(alpha: 0.12),
                        ),

                        // Compact Category Badge (Top Left, Subtle & Non-Intrusive)
                        if (item.category.isNotEmpty)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white24, width: 0.8),
                              ),
                              child: Text(
                                item.category,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),

                        // Center Circular Blue Play Button -> Plays In-App
                        Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2563EB),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30,
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
                            DownloadService.instance.launchUrlString(btn.url);
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
                        DownloadService.instance.launchUrlString('https://mrmobin.blogspot.com/');
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
      imageUrl: 'https://img.youtube.com/vi/$yId/maxresdefault.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      placeholder: (_, _) => Container(color: const Color(0xFF0F172A)),
      errorWidget: (_, _, _) => CachedNetworkImage(
        imageUrl: 'https://img.youtube.com/vi/$yId/sddefault.jpg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorWidget: (_, _, _) => CachedNetworkImage(
          imageUrl: 'https://img.youtube.com/vi/$yId/hqdefault.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorWidget: (_, _, _) => Image.asset(
            'assets/images/banner_esports.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
