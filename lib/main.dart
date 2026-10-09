import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/theme/app_theme.dart';
import 'package:security_app/core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SecuritySaaSApp(),
    ),
  );
}

class SecuritySaaSApp extends ConsumerWidget {
  const SecuritySaaSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'GatePass SaaS - Multi-Building Visitor & Security Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Shifted to positive/light mode globally
      routerConfig: goRouter,
    );
  }
}
