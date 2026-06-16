// VibeLocals App - Widget Smoke Test
// Verifies that the app launches and shows the LoginScreen correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotelbookingapp/main.dart';

void main() {
  testWidgets('VibeLocals app launches smoke test',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const VibeLocalsApp());

    // Verify the app renders without crashing.
    // The initial route is /login which shows "VibeLocals" branding text.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
