import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/preference_screen.dart';

void main() {
  testWidgets('validate text widget 1', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PreferenceScreen(),
      ),
    ));
    expect(find.text('Show Phrase'), findsOneWidget);
    expect(find.text('fingerprint'), findsOneWidget);
    expect(find.text('profile'), findsOneWidget);
    expect(find.text('settings'), findsOneWidget);
    expect(find.text('verified'), findsOneWidget);
  });

  testWidgets(
    'validate settings widget',
    (WidgetTester tester) async {
      //await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PreferenceScreen(),
      )
        ));
        expect(find.text('Settings'), findsOneWidget);
      });
   // },
//  );
}
