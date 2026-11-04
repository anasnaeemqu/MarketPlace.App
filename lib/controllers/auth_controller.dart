import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../screens/products_screen.dart';
import '../screens/login_screen.dart';

class AuthController extends GetxController {
  final String baseUrl = 'http://localhost:5033/api';
  String token = '';
  String userName = '';
  String userRole = '';
  int userId = 0;
  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    if (isLoading.value) return; // ignore taps while busy
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
        Get.snackbar(
          'Welcome back $userName!',
          'Logged in successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0077B6),
          colorText: const Color(0xFFFFFFFF),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.off(() => ProductsScreen());
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
      isLoading(false); // always runs, success or failure
    }
  }

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
        final error = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          error.toString(),
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
      print(e);
    }
  }

  void logout() {
    token = '';
    userName = '';
    userRole = '';
    userId = 0;
    Get.offAll(() => LoginScreen());
  }
}
