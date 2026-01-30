
import 'package:HamroGharSewa/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We pass isLoggedIn: false to simulate a fresh launch
    await tester.pumpWidget(const MyApp(isLoggedIn: false));
  });
}
