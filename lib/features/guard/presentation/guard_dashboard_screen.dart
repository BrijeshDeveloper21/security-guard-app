import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:security_app/features/guard/models/gate.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/features/guard/widgets/mark_exit_dialog.dart';
import 'package:security_app/features/guard/widgets/qr_scanner_dialog.dart';
import 'package:security_app/core/widgets/sync_indicator_badge.dart';
import 'package:security_app/features/guard/presentation/new_visitor_screen.dart';
import 'package:security_app/features/guard/presentation/currently_inside_screen.dart';
import 'package:security_app/features/guard/presentation/find_visitor_screen.dart';
import 'package:security_app/features/guard/presentation/emergency_view_screen.dart';
import 'package:security_app/features/guard/presentation/visitor_history_screen.dart';
import 'package:security_app/features/settings/presentation/app_settings_screen.dart';

class GuardDashboardScreen extends ConsumerWidget {
  const GuardDashboardScreen({super.key});

  String _getGreeting(WidgetRef ref) {
    final hour = DateTime.now().hour;
    final lang = ref.watch(languageProvider.notifier);
    if (hour < 12) return lang.translate('greeting_morning');
    if (hour < 17) return lang.translate('greeting_afternoon');
    return lang.translate('greeting_evening');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(currentTenantProvider);
    final activeGate = ref.watch(activeGateProvider);
    final insideList = ref.watch(currentlyInsideListProvider);
    final authService = ref.watch(authServiceProvider);
    final allGates = tenant != null
        ? ref.watch(gateServiceProvider).getGates(tenant.id, activeOnly: true)
        : <Gate>[];

    final now = DateTime.now();
    final timeStr = DateFormat('hh:mm a').format(now);
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(now);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tenant?.buildingName ?? 'Security Console',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '$dateStr • $timeStr',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
          // Language Selector
          Consumer(
            builder: (context, ref, child) {
              final lang = ref.watch(languageProvider);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  label: 'Select Application Language',
                  button: true,
                  child: Tooltip(
                    message: 'Change Language',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: lang,
                        dropdownColor: Theme.of(context).cardColor,
                        icon: const Icon(
                          Icons.language,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'EN',
                            child: Text(
                              'EN',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'HI',
                            child: Text(
                              'हिन्दी',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'MR',
                            child: Text(
                              'मराठी',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(languageProvider.notifier)
                                .setLang(val)
                                .catchError((Object error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Could not save the selected language: $error',
                                        ),
                                      ),
                                    );
                                  }
                                });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SyncIndicatorBadge(),
          ),
          Semantics(
            label: ref
                .watch(languageProvider.notifier)
                .translate('visitor_history'),
            button: true,
            child: IconButton(
              icon: Icon(
                Icons.history_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              tooltip: ref
                  .watch(languageProvider.notifier)
                  .translate('visitor_history'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VisitorHistoryScreen(),
                  ),
                );
              },
            ),
          ),
          Semantics(
            label: ref.watch(languageProvider.notifier).translate('logout'),
            button: true,
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: AppColors.statusRejected,
              ),
              tooltip: ref.watch(languageProvider.notifier).translate('logout'),
              onPressed: () {
                ref.read(authServiceProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Guard & Active Gate Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(ref),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  user?.name ?? 'Security Guard',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Gate Switcher Pill
                          Semantics(
                            label: 'Switch Active Gate',
                            child: Tooltip(
                              message: 'Switch Active Gate',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Gate>(
                                    value: activeGate,
                                    dropdownColor: Theme.of(context).cardColor,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    items: allGates.map((g) {
                                      return DropdownMenuItem<Gate>(
                                        value: g,
                                        child: Text(
                                          g.code,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newGate) {
                                      if (newGate != null) {
                                        authService.setActiveGate(newGate);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.meeting_room_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activeGate?.name ?? 'Main Gate',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Currently Inside Counter Badge
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CurrentlyInsideScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.statusInside.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.statusInside.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${insideList.length}',
                                    style: const TextStyle(
                                      color: AppColors.statusInside,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'CURRENTLY INSIDE',
                                    style: TextStyle(
                                      color: AppColors.statusInside,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: AppColors.statusInside,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  ref
                      .watch(languageProvider.notifier)
                      .translate('security_actions'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),

                // Large Action Grid
                Row(
                  children: [
                    // 1. NEW VISITOR (Primary High-Priority Flow)
                    Expanded(
                      child: _buildBigActionButton(
                        title: ref
                            .watch(languageProvider.notifier)
                            .translate('new_visitor'),
                        subtitle: ref
                            .watch(languageProvider.notifier)
                            .translate('new_visitor_sub'),
                        icon: Icons.person_add_alt_1_rounded,
                        color: AppColors.actionVisitor,
                        height: 130,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NewVisitorScreen(isDeliveryOnly: false),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 2. DELIVERY
                    Expanded(
                      child: _buildBigActionButton(
                        title: ref
                            .watch(languageProvider.notifier)
                            .translate('delivery'),
                        subtitle: ref
                            .watch(languageProvider.notifier)
                            .translate('delivery_sub'),
                        icon: Icons.local_shipping_rounded,
                        color: AppColors.actionDelivery,
                        height: 130,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NewVisitorScreen(isDeliveryOnly: true),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    // 3. SCAN QR (Cross-Gate Exit Scanner)
                    Expanded(
                      child: _buildBigActionButton(
                        title: ref
                            .watch(languageProvider.notifier)
                            .translate('scan_qr'),
                        subtitle: ref
                            .watch(languageProvider.notifier)
                            .translate('scan_qr_sub'),
                        icon: Icons.qr_code_scanner_rounded,
                        color: AppColors.actionScanQr,
                        height: 110,
                        onTap: () async {
                          final scannedVisit = await showDialog(
                            context: context,
                            builder: (_) => const QrScannerDialog(),
                          );
                          if (scannedVisit != null && context.mounted) {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  MarkExitDialog(visit: scannedVisit),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 4. FIND VISITOR
                    Expanded(
                      child: _buildBigActionButton(
                        title: ref
                            .watch(languageProvider.notifier)
                            .translate('find_visitor'),
                        subtitle: ref
                            .watch(languageProvider.notifier)
                            .translate('find_visitor_sub'),
                        icon: Icons.search_rounded,
                        color: AppColors.actionFind,
                        height: 110,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FindVisitorScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    // 5. CURRENTLY INSIDE
                    Expanded(
                      child: _buildBigActionButton(
                        title: ref
                            .watch(languageProvider.notifier)
                            .translate('currently_inside'),
                        subtitle: ref
                            .watch(languageProvider.notifier)
                            .translate('currently_inside_sub'),
                        icon: Icons.groups_rounded,
                        color: AppColors.actionInside,
                        height: 100,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CurrentlyInsideScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 6. EMERGENCY VIEW
                    Expanded(
                      child: _buildBigActionButton(
                        title: ref
                            .watch(languageProvider.notifier)
                            .translate('emergency'),
                        subtitle: ref
                            .watch(languageProvider.notifier)
                            .translate('emergency_sub'),
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.actionEmergency,
                        height: 100,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmergencyViewScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBigActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double height,
    required VoidCallback onTap,
  }) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '$title, $subtitle',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: color.withValues(alpha: 0.1),
            highlightColor: color.withValues(alpha: 0.05),
            child: Container(
              constraints: BoxConstraints(minHeight: height),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1), // Soft glow
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(height: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
