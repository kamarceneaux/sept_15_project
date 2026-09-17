import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sept_15_project/main.dart';

Future<String> _display(WidgetTester tester) async {
  return tester.widget<Text>(find.byKey(const Key('display'))).data!;
}

void main() {
  testWidgets('Calculator starts at 0', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(await _display(tester), '0');
  });

  testWidgets('Basic addition: 5 + 3 = 8', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('digit_5')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('op_add')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('digit_3')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('equals')));
    await tester.pump();

    expect(await _display(tester), '8');
  });

  testWidgets('Clear resets the display', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('digit_7')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('clear')));
    await tester.pump();

    expect(await _display(tester), '0');
  });

  testWidgets('Square root of 9 is 3', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('digit_9')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('fn_sqrt')));
    await tester.pump();

    expect(await _display(tester), '3');
  });

  testWidgets('Division by zero shows Error', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('digit_5')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('op_div')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('digit_0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('equals')));
    await tester.pump();

    expect(await _display(tester), 'Error');
  });

  testWidgets('Chained operations: 2 + 3 then x 4 = 20', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('digit_2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('op_add')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('digit_3')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('op_mul')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('digit_4')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('equals')));
    await tester.pump();

    expect(await _display(tester), '20');
  });

  testWidgets('Backspace removes the last digit', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('digit_1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('digit_2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('digit_3')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('backspace')));
    await tester.pump();

    expect(await _display(tester), '12');
  });

  testWidgets('Plus/minus toggles the sign', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('digit_9')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('plusMinus')));
    await tester.pump();

    expect(await _display(tester), '-9');

    await tester.tap(find.byKey(const Key('plusMinus')));
    await tester.pump();

    expect(await _display(tester), '9');
  });
}
