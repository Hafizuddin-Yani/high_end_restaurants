// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart'; // Unused
import 'package:flutter_test/flutter_test.dart';
import 'package:high_end_restaurants/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RestaurantApp()));

    // Verify that the app starts and shows the home screen title or loading state
    // Since we don't have data, it might show "No menu packages" or loading
    // But checking for 'Luxe Dining' which is in the AppBar is safe.
    expect(find.text('Luxe Dining'), findsOneWidget);
  });
}
