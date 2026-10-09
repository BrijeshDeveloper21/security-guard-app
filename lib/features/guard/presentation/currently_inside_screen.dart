import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/features/guard/widgets/mark_exit_dialog.dart';
import 'package:security_app/features/resident/widgets/qr_view_dialog.dart';
import 'package:security_app/core/widgets/status_chip.dart';

class CurrentlyInsideScreen extends ConsumerStatefulWidget {
  const CurrentlyInsideScreen({super.key});

  @override
  ConsumerState<CurrentlyInsideScreen> createState() => _CurrentlyInsideScreenState();
}

class _CurrentlyInsideScreenState extends ConsumerState<CurrentlyInsideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insideVisits = ref.watch(currentlyInsideListProvider);

    final filtered = insideVisits.where((v) {
      if (_searchFilter.isEmpty) return true;
      final q = _searchFilter.toLowerCase();
      return v.visitorName.toLowerCase().contains(q) ||
          v.visitorPhone.contains(q) ||
          v.flatNumber.toLowerCase().contains(q) ||
          v.id.toLowerCase().contains(q) ||
          v.entryGateName.toLowerCase().contains(q);
    }).toList();

    final timeFormatter = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CURRENTLY INSIDE',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            Text(
              '${insideVisits.length} visitors on premises',
              style: const TextStyle(fontSize: 11, color: AppColors.accent),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search by name, flat, mobile or Gate...',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                suffixIcon: _searchFilter.isNotEmpty
                    ? Semantics(
                        button: true,
                        label: 'Clear search',
                        child: IconButton(
                          icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchFilter = '');
                          },
                        ),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchFilter = val.trim()),
            ),
          ),

          // Visitor List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text(
                          _searchFilter.isEmpty
                              ? 'No visitors currently inside building'
                              : 'No matching visitors found',
                          style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final visit = filtered[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Theme.of(context).cardColor,
                                  backgroundImage: visit.visitorPhotoUrl != null
                                      ? NetworkImage(visit.visitorPhotoUrl!)
                                      : null,
                                  child: visit.visitorPhotoUrl == null
                                      ? Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 28)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              visit.visitorName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          StatusChip.fromVisitStatus(visit.status),
                                        ],
                                      ),
                                      Text(
                                        visit.id,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Flat: ${visit.flatNumber} (${visit.wingName}) • Purpose: ${visit.purpose.nameDisplay}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.borderLight, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Entered: ${timeFormatter.format(visit.entryTimestamp)}',
                                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'Gate: ${visit.entryGateName}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                                    ),
                                    Text(
                                      'Guard: ${visit.entryGuardName}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Semantics(
                                      button: true,
                                      label: 'View QR Pass',
                                      child: IconButton(
                                        icon: const Icon(Icons.qr_code_2, color: AppColors.accent),
                                        tooltip: 'View QR Pass',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => QrViewDialog(visit: visit),
                                          );
                                        },
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => MarkExitDialog(visit: visit),
                                        );
                                      },
                                      icon: const Icon(Icons.logout, size: 16),
                                      label: const Text('MARK EXIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.actionInside,
                                        minimumSize: const Size(110, 42),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
