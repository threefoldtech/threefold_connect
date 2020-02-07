import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/preference_screen.dart';

void main() {
  testWidgets('validate settings widget static text',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: PreferenceScreen(),
    )));
    // Validate all static text
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Change pincode'), findsOneWidget);
    // Partial match 'Version: '
    expect(find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final Text textWidget = widget;
        if (textWidget.data != null)
          return textWidget.data.contains('Version: ');
        return textWidget.textSpan.toPlainText().contains('Version: ');
      }
      return false;
    }), findsOneWidget);
    expect(find.text('Advanced settings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
