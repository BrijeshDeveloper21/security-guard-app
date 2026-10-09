import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:security_app/core/models/user.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/features/auth/presentation/login_screen.dart';
import 'package:security_app/features/guard/presentation/guard_dashboard_screen.dart';
import 'package:security_app/features/resident/presentation/resident_dashboard_screen.dart';
import 'package:security_app/features/admin/presentation/society_admin_screen.dart';
import 'package:security_app/features/super_admin/presentation/super_admin_screen.dart';
import 'package:security_app/core/routing/app_shell.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authService,
    redirect: (context, state) {
      final isLoggedIn = authService.isAuthenticated;
      final isGoingToLogin = state.uri.path == '/login';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      if (isLoggedIn && isGoingToLogin) {
        final role = authService.currentUser?.role;
        switch (role) {
          case UserRole.guard:
            return '/guard';
          case UserRole.resident:
            return '/resident';
          case UserRole.societyAdmin:
            return '/admin';
          case UserRole.superAdmin:
            return '/super_admin';
          default:
            return '/guard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/guard',
            builder: (context, state) => const GuardDashboardScreen(),
          ),
          GoRoute(
            path: '/resident',
            builder: (context, state) => const ResidentDashboardScreen(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const SocietyAdminScreen(),
          ),
          GoRoute(
            path: '/super_admin',
            builder: (context, state) => const SuperAdminScreen(),
          ),
        ],
      ),
    ],
  );
});
