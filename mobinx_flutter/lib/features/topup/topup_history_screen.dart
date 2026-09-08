import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/topup_request_model.dart';
import '../../core/services/topup_service.dart';
import 'package:intl/intl.dart';

class TopupHistoryScreen extends StatefulWidget {
  const TopupHistoryScreen({super.key});

  @override
  State<TopupHistoryScreen> createState() => _TopupHistoryScreenState();
}

class _TopupHistoryScreenState extends State<TopupHistoryScreen> {
  @override
  void initState() {
    super.initState();
    TopupService.instance.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Top-Up History',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<TopUpRequestModel>>(
        valueListenable: TopupService.instance.historyNotifier,
        builder: (context, history, _) {
          if (history.isEmpty) {
            return Center(
              child: Text(
                'No top-up history found.',
                style: GoogleFonts.inter(color: AppColors.textMuted),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final req = history[index];
              return _buildHistoryCard(req);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(TopUpRequestModel req) {
    Color statusColor;
    IconData statusIcon;

    switch (req.status.toLowerCase()) {
      case 'approved':
        statusColor = AppColors.emerald;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.danger;
        statusIcon = Icons.cancel_rounded;
        break;
      case 'pending':
      default:
        statusColor = AppColors.gold;
        statusIcon = Icons.hourglass_empty_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Player UID: ${req.playerId}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    req.status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Package: ${req.packageId}',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMain),
              ),
              Text(
                '৳${req.amount.toInt()}',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cyanLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${req.paymentMethod} • TrxID: ${req.trxId}',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              ),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(req.createdAt),
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
