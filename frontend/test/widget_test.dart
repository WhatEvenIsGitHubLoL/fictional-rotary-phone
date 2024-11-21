import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Calculator app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    // Verify app title
    expect(find.text('Advanced Calculator'), findsOneWidget);

    // Verify expression input field
    expect(find.byType(TextField), findsOneWidget);

    // Verify basic number buttons
    for (var i = 0; i <= 9; i++) {
      expect(find.text('$i'), findsOneWidget);
    }

    // Verify operation buttons
    expect(find.text('+'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
    expect(find.text('/'), findsOneWidget);
    expect(find.text('^'), findsOneWidget);

    // Verify special function buttons
    expect(find.text('log'), findsOneWidget);
    expect(find.text('ln'), findsOneWidget);
    expect(find.text('('), findsOneWidget);
    expect(find.text(')'), findsOneWidget);

    // Verify control buttons
    expect(find.text('C'), findsOneWidget);
    expect(find.text('⌫'), findsOneWidget);
    expect(find.text('='), findsOneWidget);

    // Test basic input
    await tester.tap(find.text('2'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('2'));
    await tester.pump();

    // Verify the expression field contains the input
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    expect((tester.widget(textField) as TextField).controller?.text, '2+2');
  });
}
