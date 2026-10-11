import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:security_app/main.dart';

import 'dart:io';

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('App launches and renders Login Screen successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SecuritySaaSApp()));

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('dwarivo'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Every arrival,'),
      ),
      findsOneWidget,
    );
    expect(find.text('Continue with mobile'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue with mobile'));
    await tester.tap(find.text('Continue with mobile'));
    await tester.pumpAndSettle();

    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Send verification code'), findsOneWidget);
  });
}
