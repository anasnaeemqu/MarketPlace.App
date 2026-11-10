import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:marketplace_app/controllers/product_controller.dart';
import 'auth_controller.dart';
import 'product_controller.dart';

class OrderController extends GetxController {
  final String baseUrl = 'http://localhost:5033/api';
  var orders = [].obs;
  var isLoading = false.obs;
  var isPlacing = false.obs;

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

  Future<void> placeOrder(int productId, double price, int quantity) async {
    if (isPlacing.value) return;
    isPlacing(true);
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
            {'productId': productId, 'quantity': quantity, 'price': price},
          ],
        }),
      );

      print('Order status: ${response.statusCode}');
      print('Order body: ${response.body}');

      if (response.statusCode == 200) {
        Get.find<ProductController>().fetchProducts();
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
        Get.snackbar(
          'Error',
          'Could not place order',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not connect to server',
        snackPosition: SnackPosition.BOTTOM,
      );
      print(e);
    } finally {
      isPlacing(false);
    }
  }

  Future<void> updateStatus(int orderId, String newStatus) async {
    try {
      final token = Get.find<AuthController>().token;
      final response = await http.put(
        Uri.parse('$baseUrl/Orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        await fetchOrders();
        Get.snackbar(
          'Updated',
          'Order #$orderId is now $newStatus',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          response.body,
          snackPosition: SnackPosition.BOTTOM,
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

  Future<void> cancelOrder(int orderId) async {
    try {
      final token = Get.find<AuthController>().token;
      final response = await http.put(
        Uri.parse('$baseUrl/Orders/$orderId/cancel'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await fetchOrders();
        if (Get.isRegistered<ProductController>()) {
          Get.find<ProductController>().fetchProducts(); // stock is back
        }
        Get.snackbar(
          'Cancelled',
          'Order #$orderId was cancelled',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          response.body,
          snackPosition: SnackPosition.BOTTOM,
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
}
