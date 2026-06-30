import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelbookingapp/presentation/module_3_map/explore_map_intro_screen.dart';

void main() {
  testWidgets('Exact Widget test for Intro Screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ExploreMapIntroScreen(),
      )
    );
    expect(find.byType(ExploreMapIntroScreen), findsOneWidget);
  });
}
