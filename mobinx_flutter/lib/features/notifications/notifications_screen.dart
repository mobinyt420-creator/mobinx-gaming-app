import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'All'},
    {'id': 'tournament', 'label': 'Tournaments'},
    {'id': 'topup', 'label': 'Top-Up'},
    {'id': 'download', 'label': 'Downloads'},
    {'id': 'referral', 'label': 'Referral'},
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textMain,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        actions: [
          TextButton(
            onPressed: () {
              NotificationService.instance.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All notifications marked as read',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Text(
              'Mark All Read',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: AppColors.borderLight),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Scroll
          Container(
            height: 52,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter['id']!;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        filter['label']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Notification List
          Expanded(
            child: ValueListenableBuilder<List<NotificationItem>>(
              valueListenable: NotificationService.instance.notificationsNotifier,
              builder: (context, allItems, _) {
                final items = NotificationService.instance.getByType(_selectedFilter);

                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('🔔', style: TextStyle(fontSize: 28)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "You're all caught up! Match alerts, top-up receipts, and offers will appear here.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notif = items[index];
                    return _buildNotificationCard(context, notif);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item) {
    String emoji = '🔔';
    Color iconBg = const Color(0xFFEFF6FF);
    if (item.type.contains('tourn')) {
      emoji = '🏆';
      iconBg = const Color(0xFFFEF3C7);
    } else if (item.type.contains('top') || item.type.contains('diamond')) {
      emoji = '💎';
      iconBg = const Color(0xFFE0F2FE);
    } else if (item.type.contains('down') || item.type.contains('apk')) {
      emoji = '📥';
      iconBg = const Color(0xFFDCFCE7);
    } else if (item.type.contains('ref') || item.type.contains('reward')) {
      emoji = '🎁';
      iconBg = const Color(0xFFF3E8FF);
    }

    return GestureDetector(
      onTap: () {
        if (item.unread) {
          NotificationService.instance.markAsRead(item.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.unread ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.unread ? AppColors.primary.withValues(alpha: 0.35) : AppColors.borderLight,
            width: item.unread ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji Box
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.timeAgo,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: AppColors.textBody,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (item.unread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
