import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/preference_screen.dart';

void main() {
  testWidgets('validate settings widget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: PreferenceScreen(),
    )));
    expect(find.text('Settings'), findsOneWidget);
  });
}
