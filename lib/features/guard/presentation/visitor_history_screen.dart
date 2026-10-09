import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/widgets/status_chip.dart';
import 'package:security_app/features/resident/widgets/qr_view_dialog.dart';

class VisitorHistoryScreen extends ConsumerStatefulWidget {
  const VisitorHistoryScreen({super.key});

  @override
  ConsumerState<VisitorHistoryScreen> createState() => _VisitorHistoryScreenState();
}

class _VisitorHistoryScreenState extends ConsumerState<VisitorHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  VisitStatus? _statusFilter;
  VisitorType? _typeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(currentTenantProvider);
    final visitorService = ref.watch(visitorServiceProvider);

    final history = tenant != null
        ? visitorService.getVisitorHistory(
            tenantId: tenant.id,
            searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
            status: _statusFilter,
            visitorType: _typeFilter,
          )
        : <Visit>[];

    final dateFormatter = DateFormat('dd MMM yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('VISITOR AUDIT HISTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.all(14),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Filter by Name, Mobile, Flat, ID, or Gate...',
                    prefixIcon: const Icon(Icons.filter_list, color: AppColors.accent),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? Semantics(
                            button: true,
                            label: 'Clear search',
                            child: IconButton(
                              icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // All Status
                      ChoiceChip(
                        label: const Text('ALL STATUS'),
                        selected: _statusFilter == null,
                        selectedColor: AppColors.primary,
                        backgroundColor: Theme.of(context).cardColor,
                        onSelected: (_) => setState(() => _statusFilter = null),
                      ),
                      const SizedBox(width: 8),
                      // Inside
                      ChoiceChip(
                        label: const Text('INSIDE'),
                        selected: _statusFilter == VisitStatus.inside,
                        selectedColor: AppColors.statusInside,
                        backgroundColor: Theme.of(context).cardColor,
                        onSelected: (_) => setState(() => _statusFilter = VisitStatus.inside),
                      ),
                      const SizedBox(width: 8),
                      // Exited
                      ChoiceChip(
                        label: const Text('EXITED'),
                        selected: _statusFilter == VisitStatus.exited,
                        selectedColor: AppColors.statusExited,
                        backgroundColor: Theme.of(context).cardColor,
                        onSelected: (_) => setState(() => _statusFilter = VisitStatus.exited),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'No visit history matching current criteria',
                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final v = history[index];
                      return Semantics(
                        button: true,
                        label: 'View Visit Details',
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => QrViewDialog(visit: v),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
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
                              // Top Bar: Name + ID + Status
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Theme.of(context).cardColor,
                                    backgroundImage: v.visitorPhotoUrl != null
                                        ? NetworkImage(v.visitorPhotoUrl!)
                                        : null,
                                    child: v.visitorPhotoUrl == null
                                        ? Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.visitorName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          '${v.id} • ${v.visitorPhone}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Flat: ${v.flatNumber} (${v.wingName}) • Purpose: ${v.purpose.nameDisplay}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusChip.fromVisitStatus(v.status),
                                ],
                              ),
                              const Divider(color: AppColors.borderLight, height: 20),

                              // Timestamps & Gates
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Entry Record
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ENTRY',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.statusApproved,
                                        ),
                                      ),
                                      Text(
                                        '${dateFormatter.format(v.entryTimestamp)} ${timeFormatter.format(v.entryTimestamp)}',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                      Text(
                                        v.entryGateName,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                                      ),
                                    ],
                                  ),

                                  // Exit Record
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'EXIT',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.statusExited,
                                        ),
                                      ),
                                      if (v.exitTimestamp != null) ...[
                                        Text(
                                          '${dateFormatter.format(v.exitTimestamp!)} ${timeFormatter.format(v.exitTimestamp!)}',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                        ),
                                        Text(
                                          v.exitGateName ?? 'Exit Gate',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                                        ),
                                      ] else ...[
                                        const Text(
                                          'STILL INSIDE',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.statusInside),
                                        ),
                                        const Text(
                                          'Active on premises',
                                          style: TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
