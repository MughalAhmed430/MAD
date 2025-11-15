
import 'package:flutter_test/flutter_test.dart';
import 'package:lab12/main.dart'; // Replace 'lab12' with your actual project name

void main() {
  testWidgets('Platform Channel app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp()); // REMOVED 'const' keyword

    // Verify that our app bar title is found
    expect(find.text('Platform Channel'), findsOneWidget);

    // Verify that device info section exists
    expect(find.text('Device info:'), findsOneWidget);
  });
}