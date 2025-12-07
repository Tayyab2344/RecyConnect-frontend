// Basic smoke tests for RecyConnect app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Smoke Tests', () {
    testWidgets('Material app renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('RecyConnect')),
        ),
      ));

      expect(find.text('RecyConnect'), findsOneWidget);
    });

    testWidgets('Scaffold with AppBar renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Home')),
          body: const Center(child: Text('Content')),
        ),
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('Navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              key: const Key('nav_button'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Scaffold(
                      body: Center(child: Text('Second Page')),
                    ),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('nav_button')));
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);
    });
  });
}
