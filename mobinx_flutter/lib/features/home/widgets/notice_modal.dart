import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/notice_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/gamer_components.dart';

/// Cyberpunk Dynamic In-App Notice & Announcement Dialog
class NoticeModal extends StatefulWidget {
  final NoticeModel notice;
  final VoidCallback? onAction;

  const NoticeModal({
    super.key,
    required this.notice,
    this.onAction,
  });

  /// Static helper to trigger the notice popup if not dismissed today
  static Future<void> showIfEligible(BuildContext context, NoticeModel notice, {VoidCallback? onAction}) async {
    final isDismissed = StorageService.isNoticeDismissedToday(notice.id);
    if (isDismissed || !notice.isActive) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => NoticeModal(
        notice: notice,
        onAction: onAction,
      ),
    );
  }

  @override
  State<NoticeModal> createState() => _NoticeModalState();
}

class _NoticeModalState extends State<NoticeModal> {
  bool _dontShowAgainToday = false;

  void _handleDismiss() async {
    if (_dontShowAgainToday) {
      await StorageService.dismissNoticeToday(widget.notice.id);
    }
    if (mounted) {
      Navigator.of(context).pop();
      widget.onAction?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.cyanLight.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyanLight.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Category Badge + Close button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.gamerGlowGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                GamerBadge(
                  text: widget.notice.category,
                  color: AppColors.cyanLight,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                  onPressed: _handleDismiss,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notice Title
            Text(
              widget.notice.title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),

            // Notice Message Body
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              child: SingleChildScrollView(
                child: Text(
                  widget.notice.message,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AppColors.textBody,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // "Don't show again today" Checkbox
            GestureDetector(
              onTap: () {
                setState(() => _dontShowAgainToday = !_dontShowAgainToday);
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _dontShowAgainToday,
                      activeColor: AppColors.primary,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      side: const BorderSide(color: AppColors.textMuted, width: 1.5),
                      onChanged: (val) {
                        setState(() => _dontShowAgainToday = val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Don't show again today",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Button
            GamerButton(
              label: widget.notice.actionText,
              onPressed: _handleDismiss,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}
