// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:lost_and_found_app/main.dart';

void main() {
  testWidgets('BUITEMS Lost & Found app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BUITEMSApp());

    // Verify that the splash screen shows 'Lost & Found'.
    expect(find.text('Lost & Found'), findsOneWidget);

    // Settle pending animations and delayed navigation timers.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
