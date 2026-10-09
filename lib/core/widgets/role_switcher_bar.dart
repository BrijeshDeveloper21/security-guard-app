import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/models/user.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/widgets/sync_indicator_badge.dart';

class RoleSwitcherBar extends ConsumerWidget {
  const RoleSwitcherBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final activeGate = authService.activeGate;

    return Container(
      color: const Color(0xFF090D16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.accent, size: 18),
              const SizedBox(width: 6),
              const Text(
                'DEMO ROLES:',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),

              // 1. Guard Gate A
              _buildRoleButton(
                title: 'Guard (Gate A)',
                isSelected: user?.role == UserRole.guard && activeGate?.code == 'GATE-A',
                color: AppColors.primary,
                onTap: () {
                  authService.setDemoSession(role: UserRole.guard, gateCode: 'GATE-A');
                },
              ),
              const SizedBox(width: 6),

              // 2. Guard Gate B
              _buildRoleButton(
                title: 'Guard (Gate B)',
                isSelected: user?.role == UserRole.guard && activeGate?.code == 'GATE-B',
                color: AppColors.accent,
                onTap: () {
                  authService.setDemoSession(role: UserRole.guard, gateCode: 'GATE-B');
                },
              ),
              const SizedBox(width: 6),

              // 3. Resident B-1204
              _buildRoleButton(
                title: 'Resident (B-1204)',
                isSelected: user?.role == UserRole.resident,
                color: Colors.teal,
                onTap: () {
                  authService.setDemoSession(role: UserRole.resident);
                },
              ),
              const SizedBox(width: 6),

              // 4. Society Admin
              _buildRoleButton(
                title: 'Society Admin',
                isSelected: user?.role == UserRole.societyAdmin,
                color: Colors.amber.shade700,
                onTap: () {
                  authService.setDemoSession(role: UserRole.societyAdmin);
                },
              ),
              const SizedBox(width: 6),

              // 5. Super Admin
              _buildRoleButton(
                title: 'Super Admin',
                isSelected: user?.role == UserRole.superAdmin,
                color: Colors.purple.shade600,
                onTap: () {
                  authService.setDemoSession(role: UserRole.superAdmin);
                },
              ),
              const SizedBox(width: 14),

              // Network toggle indicator
              const SyncIndicatorBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondaryDark,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
