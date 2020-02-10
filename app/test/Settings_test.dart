import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/preference_screen.dart';

void main() {
  testWidgets('settings screen should always have certain static text',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: PreferenceScreen(),
    )));
    // Validate all static text
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Change pincode'), findsOneWidget);
    // Partial match
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

  testWidgets('Fingerprint should not be shown by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: PreferenceScreen(),
    )));
    // Does not find fingerprint, as this only happens when the device has fingerprint
    expect(find.text('Fingerprint'), findsNothing);
  });


  testWidgets('Advanced settings should show submenu when tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: PreferenceScreen(),
    )));
    // Does not find fingerprint, as this only happens when the device has fingerprint
    var advancedSettingsButton = find.text('Advanced settings');
    expect(advancedSettingsButton, findsOneWidget);
    // Validate the elements are not yet shown
    expect(find.text('Remove Account From Device'), findsNothing);
    // Now tap the menu and pump the widget
    await tester.tap(advancedSettingsButton);
    await tester.pump();
    // Now the elements should show
    expect(find.text('Remove Account From Device'), findsOneWidget);
  });
}
