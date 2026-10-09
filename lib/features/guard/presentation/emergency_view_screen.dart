import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';

class EmergencyViewScreen extends ConsumerStatefulWidget {
  const EmergencyViewScreen({super.key});

  @override
  ConsumerState<EmergencyViewScreen> createState() => _EmergencyViewScreenState();
}

class _EmergencyViewScreenState extends ConsumerState<EmergencyViewScreen> {
  final TextEditingController _filterController = TextEditingController();
  VisitorType? _selectedTypeFilter;

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insideList = ref.watch(currentlyInsideListProvider);

    final filtered = insideList.where((v) {
      if (_selectedTypeFilter != null && v.visitorType != _selectedTypeFilter) {
        return false;
      }
      final query = _filterController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        return v.visitorName.toLowerCase().contains(query) ||
            v.flatNumber.toLowerCase().contains(query) ||
            v.visitorPhone.contains(query) ||
            v.entryGateName.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    final timeFormatter = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E0D0D),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.emergency_rounded, color: AppColors.actionEmergency, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EMERGENCY EVACUATION VIEW',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${insideList.length} Temporary Individuals Inside • Live Headcount',
                  style: const TextStyle(fontSize: 11, color: AppColors.actionEmergency),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Emergency Header Warning
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.actionEmergency.withValues(alpha: 0.18),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.actionEmergency, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'High-Priority Protocol: Direct search and location for all visitors, vendors, technicians & delivery staff for immediate muster and evacuation.',
                    style: TextStyle(color: Colors.red.shade100, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // Fast Search Bar & Category Filter
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: _filterController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Rapid filter by name, flat, mobile or gate...',
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    fillColor: const Color(0xFF171717),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        label: const Text('ALL CATEGORIES'),
                        backgroundColor: _selectedTypeFilter == null
                            ? AppColors.actionEmergency
                            : const Color(0xFF262626),
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: _selectedTypeFilter == null ? FontWeight.bold : FontWeight.normal,
                        ),
                        onPressed: () => setState(() => _selectedTypeFilter = null),
                      ),
                      const SizedBox(width: 6),
                      ...VisitorType.values.map((type) {
                        final isSel = _selectedTypeFilter == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text('${type.iconAsset} ${type.nameDisplay}'),
                            backgroundColor: isSel ? AppColors.actionEmergency : const Color(0xFF262626),
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onPressed: () => setState(() => _selectedTypeFilter = type),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // High Density Fast Emergency Table / List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No individuals inside matching emergency filter',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final v = filtered[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF333333),
                              backgroundImage: v.visitorPhotoUrl != null
                                  ? NetworkImage(v.visitorPhotoUrl!)
                                  : null,
                              child: v.visitorPhotoUrl == null
                                  ? const Icon(Icons.person, color: Colors.white70)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        v.visitorName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade900.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'FLAT ${v.flatNumber}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${v.visitorType.iconAsset} ${v.visitorType.nameDisplay} • Phone: ${v.visitorPhone}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Entry: ${timeFormatter.format(v.entryTimestamp)} via ${v.entryGateName} (Guard: ${v.entryGuardName})',
                                    style: const TextStyle(color: AppColors.actionEmergency, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
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
