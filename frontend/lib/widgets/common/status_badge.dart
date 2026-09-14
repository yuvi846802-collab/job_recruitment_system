import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'applied':
      case 'active':
        bg = AppColors.statusApplied.withValues(alpha: 0.12);
        fg = AppColors.statusApplied;
        break;
      case 'under review':
        bg = AppColors.statusUnderReview.withValues(alpha: 0.12);
        fg = AppColors.statusUnderReview;
        break;
      case 'shortlisted':
        bg = AppColors.statusShortlisted.withValues(alpha: 0.12);
        fg = AppColors.statusShortlisted;
        break;
      case 'interview scheduled':
      case 'scheduled':
        bg = AppColors.statusInterview.withValues(alpha: 0.12);
        fg = AppColors.statusInterview;
        break;
      case 'selected':
      case 'completed':
        bg = AppColors.statusSelected.withValues(alpha: 0.12);
        fg = AppColors.statusSelected;
        break;
      case 'rejected':
      case 'cancelled':
      case 'closed':
        bg = AppColors.statusRejected.withValues(alpha: 0.12);
        fg = AppColors.statusRejected;
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.12);
        fg = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),

      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
