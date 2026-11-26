import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:marketplace_app/controllers/auth_controller.dart';
import 'package:marketplace_app/main.dart';
import 'package:marketplace_app/screens/login_screen.dart';

void main() {
  setUp(() {
    // Fake, empty phone storage so the test never touches real saved data
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    // The Login screen expects this controller to exist (main() creates it in the real app)
    Get.put(AuthController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Shows the login screen when nobody is logged in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(loggedIn: false));
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
