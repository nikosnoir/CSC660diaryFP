// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/main.dart';

void main() {
  testWidgets('Diary app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the main screen title is shown.
    expect(find.text('Diary'), findsOneWidget);

    // Verify that the "No diary entries yet." message is shown initially.
    expect(find.textContaining('No diary entries yet'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that the "New Entry" screen is shown.
    expect(find.text('New Entry'), findsOneWidget);
  });
}
