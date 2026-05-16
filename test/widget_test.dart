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
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify snackbar.
    expect(find.text('Logging in as user@leafcloud.com...'), findsOneWidget);
  });
}
