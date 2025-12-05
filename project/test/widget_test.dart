import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Change this based on your pubspec.yaml name:
import 'package:campus_event_planner/main.dart';  // If name is "campus_event_planner"
// OR
// import 'package:project/main.dart';  // If name is "project"

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CampusEventPlannerApp());

    // Verify that app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);

    // Check for loading state or auth wrapper
    expect(find.byType(Scaffold), findsOneWidget);

    // Since your app doesn't have a counter, remove counter tests
    // Or test for actual elements in your app
  });
}