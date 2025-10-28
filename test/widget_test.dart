// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heart_tracker_mobile/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders call-to-action button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Masuk'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
