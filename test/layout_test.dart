import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Layout test for Intro Screen', (WidgetTester tester) async {
    // We will build a simplified version of the UI to see if it throws.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Where to?'),
                                const SizedBox(height: 20),
                                Container(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: const TextField(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text('Suggested destinations'),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: 5,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) => ListTile(title: Text('City $index')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('When'),
                              const Text('Any week'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: (){}, child: const Text('Clear all')),
                      ElevatedButton(onPressed: (){}, child: const Text('Search')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
    expect(find.text('Where to?'), findsOneWidget);
  });
}
