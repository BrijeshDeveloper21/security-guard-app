import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/theme/app_theme.dart';
import 'package:security_app/features/settings/presentation/app_settings_screen.dart';

class SuperAdminScreen extends ConsumerStatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  ConsumerState<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends ConsumerState<SuperAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showOnboardSocietyDialog(String superAdminId, String superAdminName) {
    final nameCtrl = TextEditingController();
    final bldgCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'Mumbai');
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final plans = ref.read(subscriptionServiceProvider).getPlans();
    int gateCount = 3;
    String planId = 'plan_standard';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text(
            'Onboard New Society',
            style: TextStyle(color: Colors.white),
          ),
          content: Theme(
            data: Theme.of(context)
                .copyWith(inputDecorationTheme: AppTheme.dialogInputTheme),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Society Full Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bldgCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Building Complex Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Address & Locality',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: cityCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Primary Contact Phone',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Primary Contact Email',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: planId,
                    dropdownColor: AppColors.surfaceDark,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Subscription Plan',
                    ),
                    items: plans
                        .map(
                          (plan) => DropdownMenuItem(
                            value: plan.id,
                            child: Text(plan.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => planId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Initial Gates:',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: gateCount,
                        dropdownColor: AppColors.surfaceDark,
                        items: [1, 2, 3, 4, 5, 8]
                            .map(
                              (n) => DropdownMenuItem(
                                value: n,
                                child: Text(
                                  '$n Gates',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => gateCount = val);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  ref
                      .read(superAdminServiceProvider)
                      .createSociety(
                        name: nameCtrl.text.trim(),
                        buildingName: bldgCtrl.text.trim().isNotEmpty
                            ? bldgCtrl.text.trim()
                            : nameCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        contactPhone: phoneCtrl.text.trim(),
                        contactEmail: emailCtrl.text.trim(),
                        subscriptionPlanId: planId,
                        initialGateCount: gateCount,
                        superAdminId: superAdminId,
                        superAdminName: superAdminName,
                      );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 46),
              ),
              child: const Text('Onboard Society'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final superAdminService = ref.watch(superAdminServiceProvider);
    final subService = ref.watch(subscriptionServiceProvider);
    final user = ref.watch(currentUserProvider);

    final analytics = superAdminService.getPlatformAnalytics();
    final societies = superAdminService.getAllSocieties();
    final plans = subService.getPlans();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SUPER ADMIN SaaS CONSOLE',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              'Multi-Building Platform Orchestration',
              style: TextStyle(fontSize: 11, color: AppColors.accent),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: ref
                .watch(languageProvider.notifier)
                .translate('settings_title'),
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => AppSettingsScreen.open(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.statusRejected),
            tooltip: 'Logout',
            onPressed: () => ref.read(authServiceProvider.notifier).logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'PLATFORM KPI'),
            Tab(text: 'SOCIETIES'),
            Tab(text: 'PLANS & LIMITS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Platform KPI Overview
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CROSS-TENANT PLATFORM STATS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildKpiCard(
                      'Total Societies',
                      '${analytics.totalSocieties}',
                      Icons.apartment,
                      Colors.purple,
                    ),
                    _buildKpiCard(
                      'Active Subscriptions',
                      '${analytics.activeSubscriptions}',
                      Icons.check_circle,
                      AppColors.statusApproved,
                    ),
                    _buildKpiCard(
                      'Trial Societies',
                      '${analytics.trialSubscriptions}',
                      Icons.hourglass_empty,
                      Colors.amber,
                    ),
                    _buildKpiCard(
                      'Expired / Suspended',
                      '${analytics.expiredSubscriptions}',
                      Icons.block,
                      AppColors.statusRejected,
                    ),
                    _buildKpiCard(
                      'Platform Users',
                      '${analytics.totalUsers}',
                      Icons.supervised_user_circle,
                      Colors.cyan,
                    ),
                    _buildKpiCard(
                      'Total Logged Visits',
                      '${analytics.totalVisits}',
                      Icons.history,
                      Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Societies Management
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Subscribed Societies (${societies.length})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showOnboardSocietyDialog(
                        user?.id ?? 'sa_1',
                        user?.name ?? 'Super Admin',
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Onboard Society'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(0, 46),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...societies.map((s) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                s.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: s.isActive
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.isActive ? 'ACTIVE' : 'SUSPENDED',
                                style: TextStyle(
                                  color: s.isActive
                                      ? AppColors.statusApproved
                                      : AppColors.statusRejected,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${s.address}, ${s.city} • Tenant ID: ${s.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const Divider(color: AppColors.borderDark, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plan: ${s.subscriptionPlanId.toUpperCase()}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                superAdminService.setSocietyActiveStatus(
                                  tenantId: s.id,
                                  isActive: !s.isActive,
                                  superAdminId: user?.id ?? 'sa_1',
                                  superAdminName: user?.name ?? 'Super Admin',
                                );
                              },
                              child: Text(
                                s.isActive
                                    ? 'Suspend Access'
                                    : 'Activate Society',
                                style: TextStyle(
                                  color: s.isActive ? Colors.red : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 3. Plans & Feature Limits
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONFIGURABLE SAAS TIERS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                ...plans.map((p) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: p.isPopular
                            ? AppColors.accent
                            : AppColors.borderDark,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${p.priceMonthly.toInt()} / mo',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          p.description,
                          style: const TextStyle(
                            color: AppColors.textSecondaryDark,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildLimitChip('Gates', '${p.limits.maxGates}'),
                            _buildLimitChip('Guards', '${p.limits.maxGuards}'),
                            _buildLimitChip('Flats', '${p.limits.maxFlats}'),
                            _buildLimitChip(
                              'Storage',
                              '${p.limits.storageLimitGb} GB',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
