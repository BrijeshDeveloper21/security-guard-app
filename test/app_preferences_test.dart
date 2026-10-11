import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/features/settings/presentation/app_settings_screen.dart';
import 'package:security_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('language and accessibility choices persist and reload', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(languageProvider.notifier).setLang('MR');
    await container.read(accessibilityProvider.notifier).setFontScale(1.4);
    await container.read(accessibilityProvider.notifier).setHighContrast(true);

    final reloaded = await AppPreferencesData.load();
    expect(reloaded.language, 'MR');
    expect(reloaded.fontScale, 1.4);
    expect(reloaded.highContrast, isTrue);
  });

  test('font scale is constrained to the supported range', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(accessibilityProvider.notifier).setFontScale(2);

    expect(container.read(accessibilityProvider).fontScale, 1.6);
    expect((await AppPreferencesData.load()).fontScale, 1.6);
  });

  test('unsupported language codes are rejected', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await expectLater(
      container.read(languageProvider.notifier).setLang('XX'),
      throwsArgumentError,
    );
    expect(container.read(languageProvider), 'EN');
  });

  testWidgets('settings controls render and the app honors saved preferences', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAppPreferencesProvider.overrideWithValue(
            const AppPreferencesData(fontScale: 1.2, highContrast: true),
          ),
        ],
        child: const SecuritySaaSApp(),
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.colorScheme.onSurface, Colors.black);
    expect(
      MediaQuery.of(tester.element(find.text('dwarivo'))).textScaler.scale(10),
      12,
    );

    unawaited(AppSettingsScreen.open(tester.element(find.text('dwarivo'))));
    await tester.pumpAndSettle();

    expect(find.text('Accessibility & language'), findsOneWidget);
    expect(find.text('High contrast'), findsOneWidget);
    expect(find.text('Text size'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(
      (await SharedPreferences.getInstance()).getBool(
        AppPreferencesData.highContrastKey,
      ),
      isFalse,
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hindi').last);
    await tester.pumpAndSettle();
    expect(find.text('सुगम्यता और भाषा'), findsOneWidget);
    expect((await AppPreferencesData.load()).language, 'HI');
  });
}
