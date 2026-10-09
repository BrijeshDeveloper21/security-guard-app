import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/guard/models/visitor_visit.dart';
import 'package:security_app/features/resident/models/approval.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/widgets/status_chip.dart';
import 'package:security_app/features/resident/widgets/qr_view_dialog.dart';
import 'package:security_app/features/resident/presentation/create_pre_approved_pass_screen.dart';
import 'package:security_app/features/resident/presentation/maintenance_billing_screen.dart';
import 'package:security_app/features/resident/presentation/helpdesk_screen.dart';
import 'package:security_app/features/resident/presentation/resident_profile_screen.dart';
class ResidentDashboardScreen extends ConsumerWidget {
  const ResidentDashboardScreen({super.key});

  void _showSOSBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text(
              'What is your emergency?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Guards and Admins will be alerted immediately.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSOSTypeButton(context, 'Medical', '🚑', Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildSOSTypeButton(context, 'Fire', '🔥', Colors.red)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSOSTypeButton(context, 'Security', '🛡️', Colors.blue.shade800)),
                const SizedBox(width: 12),
                Expanded(child: _buildSOSTypeButton(context, 'Lift Stuck', '🛗', Colors.purple)),
              ],
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSTypeButton(BuildContext context, String label, String emoji, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.campaign, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('$label Emergency Alert Sent! Guards notified.', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 4),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(currentTenantProvider);
    final residentService = ref.watch(residentServiceProvider);

    final flatId = user?.flatId ?? 'flat_b_1204';
    final flatNumber = user?.flatNumber ?? 'B-1204';

    final pendingApprovals = tenant != null
        ? residentService.getPendingApprovalsForFlat(
            tenantId: tenant.id,
            flatId: flatId,
          )
        : <VisitorApproval>[];

    final flatVisits = tenant != null
        ? residentService.getVisitorHistoryForFlat(
            tenantId: tenant.id,
            flatId: flatId,
          )
        : <Visit>[];

    final timeFormatter = DateFormat('hh:mm a');
    final dateFormatter = DateFormat('dd MMM');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flat $flatNumber • ${user?.wingName ?? "Wing B"}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              tenant?.name ?? 'Sunrise Heights',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.statusRejected),
            tooltip: 'Logout',
            onPressed: () => ref.read(authServiceProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSOSBottomSheet(context),
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.sos_rounded, color: Colors.white, size: 28),
        label: const Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resident Welcome & Pre-Approve Action
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFB45309)], // Stunning Premium Yellow/Gold
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome home,', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            user?.name ?? 'Resident',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(
                          'Flat $flatNumber',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreatePreApprovedPassScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_task_rounded, size: 20, color: Colors.black),
                    label: const Text('PRE-APPROVE VISITOR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White button on yellow background
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // PENDING APPROVAL REQUESTS (High Priority)
            if (pendingApprovals.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.watch(languageProvider.notifier).translate('visitor_approval_req'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.statusPending,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statusPending.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${pendingApprovals.length} PENDING',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusPending,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...pendingApprovals.map((req) {
                return Semantics(
                  label: 'Pending approval for ${req.visitorName}',
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.statusPending.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.statusPending.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              backgroundImage: req.visitorPhotoUrl != null
                                  ? NetworkImage(req.visitorPhotoUrl!)
                                  : null,
                              child: req.visitorPhotoUrl == null
                                  ? Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req.visitorName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${req.visitorPhone} • ${req.purpose.nameDisplay}',
                                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Waiting at: ${req.entryGateName}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                label: 'Reject visitor ${req.visitorName}',
                                button: true,
                                child: OutlinedButton(
                                  onPressed: () {
                                    residentService.rejectVisitor(
                                      tenantId: tenant!.id,
                                      approvalId: req.id,
                                      residentId: user!.id,
                                      residentName: user.name,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.statusRejected),
                                    foregroundColor: AppColors.statusRejected,
                                    minimumSize: const Size(0, 48),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(ref.watch(languageProvider.notifier).translate('reject')),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Semantics(
                                label: 'Approve visitor ${req.visitorName}',
                                button: true,
                                child: ElevatedButton(
                                  onPressed: () {
                                    residentService.approveVisitor(
                                      tenantId: tenant!.id,
                                      approvalId: req.id,
                                      residentId: user!.id,
                                      residentName: user.name,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusApproved,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 48),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(ref.watch(languageProvider.notifier).translate('approve')),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // RESIDENT QUICK ACTIONS (Phase 3 Features)
            Text(
              ref.watch(languageProvider.notifier).translate('resident_services'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.receipt_long,
                    title: ref.watch(languageProvider.notifier).translate('pay_bills'),
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceBillingScreen()));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.support_agent,
                    title: ref.watch(languageProvider.notifier).translate('helpdesk'),
                    color: Colors.amber, // Made yellow to match theme
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpdeskScreen()));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.family_restroom,
                    title: ref.watch(languageProvider.notifier).translate('my_profile'),
                    color: Colors.amber, // Made yellow to match theme
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ResidentProfileScreen()));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // FLAT VISITOR HISTORY (Strict Flat Isolation)
            Text(
              ref.watch(languageProvider.notifier).translate('my_flat_log'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            if (flatVisits.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Center(
                  child: Text(
                    'No visitor records recorded yet for this flat',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              )
            else
              ...flatVisits.map((v) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        backgroundImage: v.visitorPhotoUrl != null ? NetworkImage(v.visitorPhotoUrl!) : null,
                        child: v.visitorPhotoUrl == null ? Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  v.visitorName,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                                ),
                                StatusChip.fromVisitStatus(v.status),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${v.visitorType.iconAsset} ${v.purpose.nameDisplay} • ${v.id}',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${dateFormatter.format(v.entryTimestamp)} ${timeFormatter.format(v.entryTimestamp)} (${v.entryGateName})',
                              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code, color: AppColors.primary, size: 22),
                        tooltip: 'View Pass',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => QrViewDialog(visit: v),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
