import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/core/theme/app_theme.dart';
import 'package:security_app/core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppPreferencesData preferences;
  try {
    preferences = await AppPreferencesData.load();
  } catch (error, stackTrace) {
    debugPrint('Failed to load saved app preferences: $error\n$stackTrace');
    preferences = const AppPreferencesData(loadFailed: true);
  }

  runApp(
    ProviderScope(
      overrides: [initialAppPreferencesProvider.overrideWithValue(preferences)],
      child: SecuritySaaSApp(),
    ),
  );
}

class SecuritySaaSApp extends ConsumerWidget {
  const SecuritySaaSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final selectedLang = ref.watch(languageProvider);
    final accessibility = ref.watch(accessibilityProvider);

    final localeByLanguage = switch (selectedLang) {
      'HI' => const Locale('hi', 'IN'),
      'MR' => const Locale('mr', 'IN'),
      _ => const Locale('en', 'US'),
    };

    final baseTheme = accessibility.highContrast
        ? AppTheme.highContrastTheme
        : AppTheme.lightTheme;

    return MaterialApp.router(
      title: 'Dwarivo | Community Security & Visitor Management',
      debugShowCheckedModeBanner: false,
      theme: baseTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: localeByLanguage,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('mr', 'IN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final useHighContrast =
            accessibility.highContrast || mediaQuery.highContrast;

        return Theme(
          data: useHighContrast
              ? AppTheme.highContrastTheme
              : AppTheme.lightTheme,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: _CombinedTextScaler(
                mediaQuery.textScaler,
                accessibility.fontScale,
              ),
            ),
            child: Column(
              children: [
                if (ref.watch(initialAppPreferencesProvider).loadFailed)
                  const _PreferenceLoadWarning(),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            ),
          ),
        );
      },
      routerConfig: goRouter,
    );
  }
}

class _CombinedTextScaler extends TextScaler {
  const _CombinedTextScaler(this.systemScaler, this.appScale);

  final TextScaler systemScaler;
  final double appScale;

  @override
  double scale(double fontSize) => systemScaler.scale(fontSize * appScale);

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _CombinedTextScaler &&
      other.systemScaler == systemScaler &&
      other.appScale == appScale;

  @override
  int get hashCode => Object.hash(systemScaler, appScale);
}

class _PreferenceLoadWarning extends ConsumerStatefulWidget {
  const _PreferenceLoadWarning();

  @override
  ConsumerState<_PreferenceLoadWarning> createState() =>
      _PreferenceLoadWarningState();
}

class _PreferenceLoadWarningState
    extends ConsumerState<_PreferenceLoadWarning> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final translator = ref.watch(languageProvider.notifier);

    return MaterialBanner(
      content: Text(translator.translate('preferences_load_error')),
      actions: [
        TextButton(
          onPressed: () => setState(() => _dismissed = true),
          child: Text(translator.translate('dismiss')),
        ),
      ],
    );
  }
}
