import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/registered_screen.dart';

void main() {
  testWidgets('Home Screen should have certain static text',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: RegisteredScreen(),
    )));
    // Validate all static text
    expect(find.text('Threefold News Circles'), findsOneWidget);
    expect(find.text('TF Tokens'), findsOneWidget);
    expect(find.text('TF News'), findsOneWidget);
    expect(find.text('TF Grid'), findsOneWidget);
    expect(find.text('FF Nation'), findsOneWidget);
    expect(find.text('3Bot'), findsOneWidget);
    expect(find.text('More functionality will be added soon.'), findsOneWidget);
  });
}