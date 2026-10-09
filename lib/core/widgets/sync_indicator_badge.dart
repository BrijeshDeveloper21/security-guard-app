import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/widgets/status_chip.dart';

class SyncIndicatorBadge extends ConsumerWidget {
  const SyncIndicatorBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.watch(syncServiceProvider);

    return InkWell(
      onTap: () {
        // Toggle online / offline to simulate weak gate network
        final newStatus = !syncService.isOnline;
        syncService.setNetworkOnline(newStatus);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? '● Network Connected. Syncing offline records...'
                  : '● Offline Mode Active. Local entries will queue automatically.',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: newStatus ? Colors.green.shade800 : Colors.deepOrange.shade800,
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusChip.fromSyncStatus(syncService.isOnline, syncService.syncStatus),
            if (syncService.pendingQueueCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${syncService.pendingQueueCount} queued',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
