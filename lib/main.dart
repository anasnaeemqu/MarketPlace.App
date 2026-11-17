import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'screens/login_screen.dart';
import 'screens/products_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = Get.put(AuthController());
  final loggedIn = await auth.tryAutoLogin(); // read the saved session first

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Marketplace',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: loggedIn ? const ProductsScreen() : const LoginScreen(),
    );
  }
}
