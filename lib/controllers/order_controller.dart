import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_controller.dart';
import '../screens/products_screen.dart';

class OrderController extends GetxController {
  final String baseUrl = 'http://localhost:5033/api';
  var orders = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      final token = Get.find<AuthController>().token;
      final response = await http.get(
        Uri.parse('$baseUrl/Orders'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        orders.value = jsonDecode(response.body);
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> placeOrder(
    int productId,
    double price,
    int quantity,
  ) async {
    try {
      print('placeOrder function started!');
      final token = Get.find<AuthController>().token;
      print('Token length: ${token.length}');

      final response = await http.post(
        Uri.parse('$baseUrl/Orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customerId': 1,
          'items': [
            {
              'productId': productId,
              'quantity': quantity,
              'price': price,
            }
          ]
        }),
      );

      print('Order status: ${response.statusCode}');
      print('Order body: ${response.body}');

      if (response.statusCode == 200) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        Get.snackbar(
          'Success',
          'Order placed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar('Error', 'Could not place order',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server',
          snackPosition: SnackPosition.BOTTOM);
      print(e);
    }
  }
}