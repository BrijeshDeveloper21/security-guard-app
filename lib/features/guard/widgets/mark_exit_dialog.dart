import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/features/guard/models/gate.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/widgets/status_chip.dart';

class MarkExitDialog extends ConsumerStatefulWidget {
  final Visit visit;

  const MarkExitDialog({super.key, required this.visit});

  @override
  ConsumerState<MarkExitDialog> createState() => _MarkExitDialogState();
}

class _MarkExitDialogState extends ConsumerState<MarkExitDialog> {
  Gate? _selectedExitGate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default exit gate to current guard's assigned gate
    _selectedExitGate = ref.read(activeGateProvider);
  }

  Future<void> _handleConfirmExit() async {
    final tenant = ref.read(currentTenantProvider);
    final user = ref.read(currentUserProvider);
    final gate = _selectedExitGate ?? ref.read(activeGateProvider);

    if (tenant == null || user == null || gate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exit gate')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final visitorService = ref.read(visitorServiceProvider);
      await visitorService.recordCrossGateExit(
        tenantId: tenant.id,
        visitId: widget.visit.id,
        exitGateId: gate.id,
        exitGateName: gate.name,
        exitGuardId: user.id,
        exitGuardName: user.name,
      );

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Exit recorded automatically at ${gate.name} for ${widget.visit.visitorName}',
          ),
          backgroundColor: AppColors.statusApproved,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking exit: $e'),
          backgroundColor: AppColors.statusRejected,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(currentTenantProvider);
    final allGates = tenant != null
        ? ref.watch(gateServiceProvider).getGates(tenant.id, activeOnly: true)
        : <Gate>[];

    final timeFormatter = DateFormat('hh:mm a');
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CONFIRM VISITOR EXIT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
                StatusChip.fromVisitStatus(widget.visit.status),
              ],
            ),
            const SizedBox(height: 16),

            // Visitor Banner Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.surfaceDark,
                    backgroundImage: widget.visit.visitorPhotoUrl != null
                        ? NetworkImage(widget.visit.visitorPhotoUrl!)
                        : null,
                    child: widget.visit.visitorPhotoUrl == null
                        ? const Icon(Icons.person, size: 34, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.visit.visitorName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.visit.id,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Destination: Flat ${widget.visit.flatNumber} (${widget.visit.wingName})',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Entry Details (Audit comparison)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                children: [
                  _buildRow('Purpose', widget.visit.purpose.nameDisplay),
                  _buildRow('Entry Gate', widget.visit.entryGateName),
                  _buildRow(
                    'Entry Time',
                    '${dateFormatter.format(widget.visit.entryTimestamp)} at ${timeFormatter.format(widget.visit.entryTimestamp)}',
                  ),
                  _buildRow('Entry Guard', widget.visit.entryGuardName),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Exit Gate Selector (Cross-Gate Exit selection)
            const Text(
              'Select Exit Gate:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Gate>(
                  value: _selectedExitGate,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceDark,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: allGates.map((gate) {
                    final isCrossGate = gate.id != widget.visit.entryGateId;
                    return DropdownMenuItem<Gate>(
                      value: gate,
                      child: Text(
                        '${gate.name} ${isCrossGate ? "(Cross-Gate)" : ""}',
                        style: TextStyle(
                          color: isCrossGate ? AppColors.accent : Colors.white,
                          fontWeight: isCrossGate ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedExitGate = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Automatic Exit Time Notice
            Row(
              children: [
                const Icon(Icons.auto_mode_rounded, size: 16, color: AppColors.statusApproved),
                const SizedBox(width: 6),
                Text(
                  'Exit time will be automatically recorded as: ${timeFormatter.format(DateTime.now())}',
                  style: const TextStyle(fontSize: 11, color: AppColors.statusApproved),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      minimumSize: const Size(0, 52),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleConfirmExit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.logout_rounded),
                    label: const Text(
                      'MARK EXIT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusInside,
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
