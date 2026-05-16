import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:leaf_cloud/main.dart';

void main() {
  testWidgets('LeafCloud custom login theme test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LoginApp());

    // Verify presence of custom design elements.
    expect(find.text('LeafCloud'), findsOneWidget);
    expect(find.text('Smart Hydroponics Monitoring'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Connection Settings'), findsOneWidget);

    // Verify input fields are present via hint text.
    expect(find.text('Email or Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Interact with form.
    await tester.enterText(find.byType(TextFormField).at(0), 'user@leafcloud.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    
    // Tap login.
    await tester.tap(find.text('Login'));
    
    // We don't pump() immediately to check the loading indicator because the 
    // network call (returning 400 immediately in tests) might complete in the same frame.
    // Instead, we just settle everything.
    await tester.pumpAndSettle();

    // In a test environment, real http calls fail/return 400.
    // Our code handles this by showing an error snackbar.
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Error'), findsOneWidget);
  });
}
