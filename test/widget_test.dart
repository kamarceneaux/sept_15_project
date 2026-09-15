// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sept_15_project/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.byKey(const Key('counterText')), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2)); // counter display + reset button

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(
      tester.widget<Text>(find.byKey(const Key('counterText'))).data,
      '1',
    );
  });

  testWidgets('Counter decrements three times when "-" is pressed',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(
      tester.widget<Text>(find.byKey(const Key('counterText'))).data,
      '0',
    );

    // Tap the '-' icon three times, triggering a frame after each tap.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
    }

    // Verify that the counter decremented by 3.
    expect(
      tester.widget<Text>(find.byKey(const Key('counterText'))).data,
      '-3',
    );
  });
}
