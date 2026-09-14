import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('JRMS App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const JRMSApp());
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('JRMS PORTAL'), findsNothing); // Navigated past splash screen
  });
}
