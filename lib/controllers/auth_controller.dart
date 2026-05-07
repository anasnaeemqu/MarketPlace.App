import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../screens/products_screen.dart';

class AuthController extends GetxController {
  final String baseUrl = 'http://localhost:5033/api';
  String token = '';

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'];
        Get.snackbar('Success', 'Logged in successfully!');
        Get.off(() => ProductsScreen()); // 👈 Navigate to Products
      } else {
        Get.snackbar('Error', 'Invalid email or password');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server');
      print(e);
    }
  }
}