import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';

void main() {
  testWidgets('authentication screen should have certain text and buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: AuthenticationScreen(userMessage: 'Hello test test',correctPin: "0000",),
    )));   
    // Validate pin input screen
    expect(find.text('Authentication'), findsOneWidget);
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
    expect(find.text('Please authenticate to Hello test test'), findsOneWidget);
  });

  
  testWidgets('entering the wrong pin should say that it is wrong',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: AuthenticationScreen(userMessage: 'Hello test test',correctPin: "0000",),
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
    expect(find.text('Incorrect pin'), findsOneWidget);
    expect(find.text('Your pincode is incorrect.'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
  });
}