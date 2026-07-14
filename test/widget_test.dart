import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bruh/main.dart';

void main() {
  testWidgets('Aura app renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AuraApp());

    // The hero title should be on screen.
    expect(find.text('Aura'), findsOneWidget);

    // The first mood (Hearth) should be selected by default.
    expect(find.text('Hearth'), findsWidgets);
  });
}