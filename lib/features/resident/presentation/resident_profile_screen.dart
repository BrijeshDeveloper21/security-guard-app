import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';

class ResidentProfileScreen extends ConsumerStatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  ConsumerState<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends ConsumerState<ResidentProfileScreen> {
  final List<Map<String, String>> _familyMembers = [
    {'name': 'Ritu Sharma', 'relation': 'Wife'},
    {'name': 'Aryan Sharma', 'relation': 'Son'},
  ];

  final List<Map<String, String>> _vehicles = [
    {'name': 'Honda City', 'number': 'MH-02-CB-1234'},
    {'name': 'Activa 6G', 'number': 'MH-02-AB-9876'},
  ];

  void _showAddDialog(String type) {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(); // Added phone controller

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Add $type', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: type == 'Family Member' ? 'Name' : 'Vehicle Model'),
            ),
            const SizedBox(height: 12),
            if (type == 'Family Member') ...[
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: subtitleCtrl,
              decoration: InputDecoration(labelText: type == 'Family Member' ? 'Relationship' : 'Registration Number'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && subtitleCtrl.text.isNotEmpty) {
                setState(() {
                  if (type == 'Family Member') {
                    _familyMembers.add({'name': titleCtrl.text, 'relation': subtitleCtrl.text, 'phone': phoneCtrl.text});
                  } else {
                    _vehicles.add({'name': titleCtrl.text, 'number': subtitleCtrl.text});
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(currentTenantProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.name.substring(0, 1) ?? 'R',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Resident Name',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Flat ${user?.flatNumber} (${user?.wingName})',
                    style: const TextStyle(fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tenant?.name ?? 'Sunrise Heights',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Family Members Section
            _buildSectionHeader('FAMILY MEMBERS', Icons.family_restroom),
            const SizedBox(height: 12),
            ..._familyMembers.map((fm) => _buildListItem(
                  title: fm['name']!,
                  subtitle: '${fm['relation']!} ${fm.containsKey('phone') && fm['phone']!.isNotEmpty ? '• ${fm['phone']}' : ''}',
                  icon: Icons.person_outline,
                )),
            _buildAddButton(context, 'Family Member'),
            
            const SizedBox(height: 32),

            // Vehicles Section
            _buildSectionHeader('MY VEHICLES', Icons.directions_car),
            const SizedBox(height: 12),
            ..._vehicles.map((v) => _buildListItem(
                  title: v['name']!,
                  subtitle: v['number']!,
                  icon: Icons.directions_car_outlined,
                )),
            _buildAddButton(context, 'Vehicle'),
            
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () {
                ref.read(authServiceProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusRejected.withValues(alpha: 0.1),
                foregroundColor: AppColors.statusRejected,
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
                side: const BorderSide(color: AppColors.statusRejected),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondaryDark),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondaryDark,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem({required String title, required String subtitle, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondaryDark),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, String type) {
    return Semantics(
      button: true,
      label: 'Add $type',
      child: InkWell(
        onTap: () => _showAddDialog(type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Add $type', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
