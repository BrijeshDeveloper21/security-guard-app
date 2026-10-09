import 'package:flutter/material.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/models/sync_queue.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusChip.fromVisitStatus(VisitStatus status) {
    switch (status) {
      case VisitStatus.inside:
        return const StatusChip(
          label: 'INSIDE',
          color: AppColors.statusInside,
          icon: Icons.login_rounded,
        );
      case VisitStatus.exited:
        return const StatusChip(
          label: 'EXITED',
          color: AppColors.statusExited,
          icon: Icons.logout_rounded,
        );
      case VisitStatus.rejected:
        return const StatusChip(
          label: 'REJECTED',
          color: AppColors.statusRejected,
          icon: Icons.cancel_outlined,
        );
    }
  }

  factory StatusChip.fromApprovalStatus(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return const StatusChip(
          label: 'APPROVED',
          color: AppColors.statusApproved,
          icon: Icons.check_circle_outline_rounded,
        );
      case ApprovalStatus.pending:
        return const StatusChip(
          label: 'PENDING',
          color: AppColors.statusPending,
          icon: Icons.hourglass_top_rounded,
        );
      case ApprovalStatus.rejected:
        return const StatusChip(
          label: 'REJECTED',
          color: AppColors.statusRejected,
          icon: Icons.block_rounded,
        );
      case ApprovalStatus.notRequired:
        return const StatusChip(
          label: 'AUTO APPROVED',
          color: AppColors.statusApproved,
          icon: Icons.verified_user_outlined,
        );
    }
  }

  factory StatusChip.fromSyncStatus(bool isOnline, SyncStatus syncStatus) {
    if (!isOnline) {
      return const StatusChip(
        label: 'OFFLINE',
        color: AppColors.statusOffline,
        icon: Icons.cloud_off_rounded,
      );
    }
    if (syncStatus == SyncStatus.syncing) {
      return const StatusChip(
        label: 'SYNCING...',
        color: AppColors.statusSyncing,
        icon: Icons.sync_rounded,
      );
    }
    return const StatusChip(
      label: 'ONLINE',
      color: AppColors.statusOnline,
      icon: Icons.cloud_done_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12), // Softer Figma style background
        borderRadius: BorderRadius.circular(12), // slightly less rounded to match cards
        // Removed border completely for a cleaner Figma style chip
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
