import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mimeng_leafcloud_app_v2/main.dart';

void main() {
  testWidgets('Login form smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LoginApp());

    // Verify that the login form elements are present.
    // 'Login' appears in AppBar and Button
    expect(find.text('Login'), findsAtLeast(1));
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Enter some text and tap login.
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify snackbar appears (simulated login).
    expect(find.text('Logging in as test@example.com...'), findsOneWidget);
  });
}
