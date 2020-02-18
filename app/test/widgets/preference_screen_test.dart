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
    expect(find.text('Advanced settings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
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
    var advancedSettingsButton = find.text('Advanced settings');
    expect(advancedSettingsButton, findsOneWidget);
    // Validate the elements are not yet shown
    expect(find.text('Remove Account From Device'), findsNothing);
    // Now tap the menu and pump the widget
    await tester.tap(advancedSettingsButton);
    await tester.pumpAndSettle();
    // Now the elements should show
    expect(find.text('Remove Account From Device'), findsOneWidget);
  });

  testWidgets('Remove account should show warning/confirmation',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: PreferenceScreen(),
    )));
    // Find advanced settings button, tap it
    var advancedSettingsButton = find.text('Advanced settings');
    await tester.tap(advancedSettingsButton);
    await tester.pumpAndSettle();
    // Find remove account button, tap it
    var removeAccountButton = find.text('Remove Account From Device');
    await tester.tap(removeAccountButton);
    await tester.pumpAndSettle();
    //Now the warning dialog should show
    expect(find.text('Are you sure?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
  });

  testWidgets('settings screen should always have certain icons',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: PreferenceScreen(),
    )));
    // Validate icons are shown
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.mail), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
}
