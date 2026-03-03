// Basic widget smoke test for the Traffic Alert app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:traffic_alert/main.dart';

void main() {
  testWidgets('App builds and shows tab bar', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrafficAlertApp()));
    await tester.pump();

    // Verify that the tab bar is present with both tabs
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
  });
}
