import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/main.dart';

void main() {
  testWidgets('Renders Security SaaS Platform and verifies Guard Dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SecuritySaaSApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify presence of Guard interface and core security buttons
    expect(find.text('NEW VISITOR'), findsOneWidget);
    expect(find.text('SCAN QR'), findsOneWidget);
    expect(find.text('FIND VISITOR'), findsOneWidget);
    expect(find.text('CURRENTLY INSIDE'), findsWidgets);
    expect(find.text('EMERGENCY VIEW'), findsOneWidget);
  });
}
