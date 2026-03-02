import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vora/frontend/pages/wellness_hub_screen.dart';

void main() {
  testWidgets('Wellness hub renders expected content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WellnessHubScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(find.text('Wellness Hub'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });
}
