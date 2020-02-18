import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/change_pin_screen.dart';

void main() {
  testWidgets('change pin screen should have all buttons and title/text',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: ChangePinScreen(
        currentPin: "9999",
        hideBackButton: false,
      ),
    )));
    // Validate pin input screen
    expect(find.text('Please enter your new PIN'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Change pincode'), findsOneWidget);
  });

  testWidgets('entering a new pin should prompt the next screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ChangePinScreen(
        currentPin: "9999",
        hideBackButton: false,
      ),
    )));
    // Validate pin input screen
    var nineButton = find.text('9');
    expect(nineButton, findsOneWidget);
    await tester.tap(nineButton);
    await tester.pumpAndSettle();
    await tester.tap(nineButton);
    await tester.pumpAndSettle();
    await tester.tap(nineButton);
    await tester.pumpAndSettle();
    await tester.tap(nineButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Please confirm your new PIN'), findsOneWidget);
  });

    testWidgets('confirming the wrong pin should restart the process',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ChangePinScreen(
        currentPin: "9999",
        hideBackButton: false,
      ),
    )));
    // Validate pin input screen
    var nineButton = find.text('9');
    expect(nineButton, findsOneWidget);
    await tester.tap(nineButton);
    await tester.pumpAndSettle();
    await tester.tap(nineButton);
    await tester.pumpAndSettle();
    await tester.tap(nineButton);
    await tester.pumpAndSettle();
    await tester.tap(nineButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Please confirm your new PIN'), findsOneWidget);
    var oneButton = find.text('1');
    expect(oneButton, findsOneWidget);
    await tester.tap(oneButton);
    await tester.pumpAndSettle();
    await tester.tap(oneButton);
    await tester.pumpAndSettle();
    await tester.tap(oneButton);
    await tester.pumpAndSettle();
    await tester.tap(oneButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmation incorrect, please enter your new PIN'), findsOneWidget);
  });
}
