import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/features/resident/models/tenant.dart';
import 'package:security_app/features/guard/models/gate.dart';
import 'package:security_app/features/resident/models/flat.dart';
import 'package:security_app/features/resident/models/guard_resident.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';

class SocietyAdminScreen extends ConsumerStatefulWidget {
  const SocietyAdminScreen({super.key});

  @override
  ConsumerState<SocietyAdminScreen> createState() => _SocietyAdminScreenState();
}

class _SocietyAdminScreenState extends ConsumerState<SocietyAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Add Gate Dialog ---
  void _showAddGateDialog(String tenantId, String adminId, String adminName) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    GateType selectedType = GateType.mainEntrance;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Add Dynamic Gate', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Gate Name (e.g. Gate D - Service)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Gate Code (e.g. GATE-D)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<GateType>(
                initialValue: selectedType,
                dropdownColor: AppColors.surfaceDark,
                style: const TextStyle(color: Colors.white),
                items: GateType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.nameDisplay))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && codeCtrl.text.isNotEmpty) {
                  ref.read(gateServiceProvider).addGate(
                    tenantId: tenantId,
                    name: nameCtrl.text.trim(),
                    code: codeCtrl.text.trim(),
                    type: selectedType,
                    adminUserId: adminId,
                    adminUserName: adminName,
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Add Gate'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Add Flat Dialog ---
  void _showAddFlatDialog(String tenantId, String adminId, String adminName, List<Wing> wings) {
    if (wings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one wing first')),
      );
      return;
    }

    final flatNumCtrl = TextEditingController();
    final resNameCtrl = TextEditingController();
    final resPhoneCtrl = TextEditingController();
    Wing selectedWing = wings.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Add Flat', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Wing>(
                initialValue: selectedWing,
                dropdownColor: AppColors.surfaceDark,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Select Wing'),
                items: wings.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedWing = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: flatNumCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Flat Number (e.g. B-1205)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: resNameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Resident Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: resPhoneCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Resident Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (flatNumCtrl.text.isNotEmpty) {
                  ref.read(societyServiceProvider).addFlat(
                    tenantId: tenantId,
                    wingId: selectedWing.id,
                    wingName: selectedWing.name,
                    flatNumber: flatNumCtrl.text.trim(),
                    floor: 1,
                    residentName: resNameCtrl.text.trim().isNotEmpty ? resNameCtrl.text.trim() : null,
                    residentPhone: resPhoneCtrl.text.trim().isNotEmpty ? resPhoneCtrl.text.trim() : null,
                    adminId: adminId,
                    adminName: adminName,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Flat'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(currentTenantProvider);
    final user = ref.watch(currentUserProvider);
    final societyService = ref.watch(societyServiceProvider);
    final gateService = ref.watch(gateServiceProvider);
    final subService = ref.watch(subscriptionServiceProvider);

    if (tenant == null) {
      return const Scaffold(body: Center(child: Text('Tenant not loaded')));
    }

    // Check Subscription Access Control
    if (!tenant.isSubscriptionActive) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.statusRejected, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.statusRejected),
                const SizedBox(height: 16),
                Text(
                  'SUBSCRIPTION EXPIRED',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'The subscription for ${tenant.name} expired on ${tenant.subscriptionExpiresAt.toLocal().toString().split(" ")[0]}. Historical records are preserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    subService.setSubscriptionStatus(
                      tenantId: tenant.id,
                      status: SubscriptionStatus.active,
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusApproved, foregroundColor: Colors.white, elevation: 0),
                  child: const Text('RENEW SUBSCRIPTION NOW'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stats = societyService.getDashboardStats(tenant.id);
    final gates = gateService.getGates(tenant.id);
    final wings = societyService.getWings(tenant.id);
    final flats = societyService.getFlats(tenant.id);
    final guards = societyService.getGuards(tenant.id);
    final residents = societyService.getResidents(tenant.id);
    final subscription = subService.getSubscriptionForTenant(tenant.id);
    final plan = subService.getPlanById(tenant.subscriptionPlanId);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tenant.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              'Society Admin Console • Plan: ${plan?.name ?? "Standard"}',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'DASHBOARD'),
            Tab(text: 'GATES'),
            Tab(text: 'WINGS & FLATS'),
            Tab(text: 'GUARDS'),
            Tab(text: 'RESIDENTS'),
            Tab(text: 'SUBSCRIPTION'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Dashboard Overview Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TODAY\'S ACTIVITY METRICS', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildKpiCard('Visitors Today', '${stats.visitorsToday}', Icons.people_alt, Colors.blue),
                    _buildKpiCard('Currently Inside', '${stats.currentlyInside}', Icons.login_rounded, AppColors.statusInside),
                    _buildKpiCard('Pending Approvals', '${stats.pendingApprovals}', Icons.hourglass_top, AppColors.statusPending),
                    _buildKpiCard('Exited Today', '${stats.exitedToday}', Icons.logout_rounded, AppColors.statusExited),
                    _buildKpiCard('Active Guards', '${stats.activeGuards}', Icons.security, AppColors.statusApproved),
                    _buildKpiCard('Configured Gates', '${stats.activeGates}', Icons.meeting_room, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 24),

                // Building Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BUILDING PROFILE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      Text('Address: ${tenant.address}, ${tenant.city}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Contact: ${tenant.contactPhone} • ${tenant.contactEmail}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text('Timezone: ${tenant.timezone}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Gates Management Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Gates (${gates.length})', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                    Semantics(
                      label: 'Add New Gate',
                      button: true,
                      child: Tooltip(
                        message: 'Add New Gate',
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddGateDialog(tenant.id, user!.id, user.name),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Gate'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...gates.map((g) {
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
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            g.type == GateType.parking ? Icons.local_parking : Icons.meeting_room,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                              Text('${g.code} • ${g.type.nameDisplay}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Switch(
                          value: g.isActive,
                          activeThumbColor: AppColors.statusApproved,
                          onChanged: (val) {
                            gateService.toggleGateStatus(
                              tenantId: tenant.id,
                              gateId: g.id,
                              isActive: val,
                              adminUserId: user!.id,
                              adminUserName: user.name,
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

          // 3. Wings & Flats Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Flats (${flats.length})', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                    Semantics(
                      label: 'Add New Flat',
                      button: true,
                      child: Tooltip(
                        message: 'Add New Flat',
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddFlatDialog(tenant.id, user!.id, user.name, wings),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Flat'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...flats.map((f) {
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
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flat ${f.flatNumber} (${f.wingName})',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              f.residentName != null
                                  ? 'Resident: ${f.residentName} (${f.residentPhone ?? ""})'
                                  : 'Vacant / Unassigned',
                              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: f.isOccupied ? AppColors.statusApproved.withValues(alpha: 0.1) : AppColors.textMutedLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            f.isOccupied ? 'Occupied' : 'Vacant',
                            style: TextStyle(
                              color: f.isOccupied ? AppColors.statusApproved : AppColors.textSecondaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 4. Guards Management Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                ...guards.map((g) {
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
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.shield_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                              const SizedBox(height: 2),
                              Text('Assigned: ${g.assignedGateName} • ${g.phone}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              const SizedBox(height: 2),
                              Text('Shift: ${g.shift.nameDisplay}', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: g.isOnDuty ? AppColors.statusApproved.withValues(alpha: 0.1) : AppColors.textMutedLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            g.isOnDuty ? 'ON DUTY' : 'OFF DUTY',
                            style: TextStyle(
                              color: g.isOnDuty ? AppColors.statusApproved : AppColors.textSecondaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 5. Residents Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                ...residents.map((r) {
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
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                              const SizedBox(height: 2),
                              Text('Flat: ${r.flatNumber} (${r.wingName}) • ${r.phone}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 6. Subscription Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CURRENT PLAN: ${plan?.name.toUpperCase() ?? "STANDARD"}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tenant.subscriptionStatus.nameDisplay,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Billing: ₹${plan?.priceYearly.toStringAsFixed(0)} / Year',
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Valid until: ${tenant.subscriptionExpiresAt.toLocal().toString().split(" ")[0]}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text('SIMULATE EXPIRATION TEST', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    subService.setSubscriptionStatus(
                      tenantId: tenant.id,
                      status: SubscriptionStatus.expired,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.statusRejected),
                    foregroundColor: AppColors.statusRejected,
                  ),
                  child: const Text('Simulate Subscription Expired State'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color) {
    return Semantics(
      label: 'Metric: $title, Count: $count',
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            Text(count, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 28, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
