import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/features/guard/widgets/mark_exit_dialog.dart';
import 'package:security_app/core/widgets/status_chip.dart';

class FindVisitorScreen extends ConsumerStatefulWidget {
  const FindVisitorScreen({super.key});

  @override
  ConsumerState<FindVisitorScreen> createState() => _FindVisitorScreenState();
}

class _FindVisitorScreenState extends ConsumerState<FindVisitorScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Visit> _searchResults = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final tenant = ref.read(currentTenantProvider);
    if (tenant == null || query.trim().isEmpty) return;

    final visitorService = ref.read(visitorServiceProvider);
    final results = visitorService.getVisitorHistory(
      tenantId: tenant.id,
      searchQuery: query.trim(),
    );

    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('hh:mm a');
    final dateFormatter = DateFormat('dd MMM');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('FIND VISITOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Input Field
            TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search by Mobile, Name, Flat, or Visit ID...',
                prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                suffixIcon: Semantics(
                  button: true,
                  label: 'Search',
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.accent),
                    onPressed: () => _performSearch(_searchController.text),
                  ),
                ),
              ),
              onSubmitted: _performSearch,
              onChanged: (val) {
                if (val.trim().length >= 3) _performSearch(val);
              },
            ),
            const SizedBox(height: 16),

            // Search Results
            Expanded(
              child: !_hasSearched
                  ? const Center(
                      child: Text(
                        'Type mobile number, name, or flat number to find visitor',
                        style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No visitor found matching query',
                            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 15),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _searchResults.length,
                          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final visit = _searchResults[index];
                            final isInside = visit.status == VisitStatus.inside;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isInside ? AppColors.accent.withValues(alpha: 0.5) : AppColors.borderLight,
                                ),
                                boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        visit.visitorName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      StatusChip.fromVisitStatus(visit.status),
                                    ],
                                  ),
                                  Text(
                                    '${visit.visitorPhone} • Flat: ${visit.flatNumber} (${visit.wingName})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ID: ${visit.id} • Purpose: ${visit.purpose.nameDisplay}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Entry: ${dateFormatter.format(visit.entryTimestamp)} ${timeFormatter.format(visit.entryTimestamp)} (${visit.entryGateName})',
                                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ),
                                      if (isInside)
                                        ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => MarkExitDialog(visit: visit),
                                            ).then((_) {
                                              _performSearch(_searchController.text);
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.actionInside,
                                            minimumSize: const Size(100, 38),
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                          ),
                                          child: const Text(
                                            'MARK EXIT',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        )
                                      else if (visit.exitTimestamp != null)
                                        Text(
                                          'Exited: ${timeFormatter.format(visit.exitTimestamp!)} (${visit.exitGateName ?? ""})',
                                          style: const TextStyle(fontSize: 11, color: AppColors.statusExited),
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
      ),
    );
  }
}
