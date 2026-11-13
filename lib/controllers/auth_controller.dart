import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/products_screen.dart';
import '../screens/login_screen.dart';

class AuthController extends GetxController {
  final String baseUrl = 'http://localhost:5033/api';
  String token = '';
  String userName = '';
  String userRole = '';
  int userId = 0;
  var isLoading = false.obs;

  // ---------- AUTO LOGIN ----------

  /// Called once at app start. Returns true if a valid saved session exists.
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');

    if (savedToken == null || savedToken.isEmpty) return false;

    if (_isExpired(savedToken)) {
      await prefs.clear(); // old page in the notebook, tear it out
      return false;
    }

    token = savedToken;
    userName = prefs.getString('userName') ?? '';
    userRole = prefs.getString('userRole') ?? '';
    userId = prefs.getInt('userId') ?? 0;
    return true;
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userName', userName);
    await prefs.setString('userRole', userRole);
    await prefs.setInt('userId', userId);
  }

  /// A JWT is 3 parts separated by dots. The middle part holds "exp"
  /// (expiry time in seconds). We read it without any extra package.
  bool _isExpired(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return true;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final exp = jsonDecode(payload)['exp'] as int;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      // treat "expires within 1 minute" as already expired
      return DateTime.now().isAfter(
        expiry.subtract(const Duration(minutes: 1)),
      );
    } catch (_) {
      return true; // can't read it → don't trust it
    }
  }

  // ---------- LOGIN ----------

  Future<void> login(String email, String password) async {
    if (isLoading.value) return;
    isLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'];
        userName = data['name'];
        userRole = data['role'];
        userId = data['userId'];
        await _saveSession(); // 👈 write it in the notebook

        Get.snackbar(
          'Welcome back $userName!',
          'Logged in successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0077B6),
          colorText: const Color(0xFFFFFFFF),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.off(() => const ProductsScreen());
      } else {
        Get.snackbar(
          'Error',
          response.body,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not connect to server',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // ---------- REGISTER ----------

  Future<void> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Account created! Please login.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          response.body,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not connect to server',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------- LOGOUT ----------

  Future<void> logout() async {
    token = '';
    userName = '';
    userRole = '';
    userId = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 👈 tear the page out of the notebook

    Get.offAll(() => LoginScreen());
  }

  /// Call this when the server answers 401 (token expired mid-session).
  void sessionExpired() {
    Get.snackbar(
      'Session expired',
      'Please log in again',
      snackPosition: SnackPosition.BOTTOM,
    );
    logout();
  }
}
