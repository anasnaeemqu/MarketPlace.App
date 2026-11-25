import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../widgets/common.dart';
import 'auth_controller.dart';
import 'product_controller.dart';

class OrderController extends GetxController {
  final String baseUrl = apiBaseUrl;

  var orders = [].obs;
  var isLoading = false.obs;
  var isPlacing = false.obs; // the "Occupied" sign for the Place order button

  // The Orders screen calls fetchOrders() itself when it opens,
  // so nothing is fetched here. That avoids a pointless request every time
  // a product page is opened.

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${Get.find<AuthController>().token}',
  };

  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('$baseUrl/Orders'),
        headers: _authHeaders,
      );

      if (response.statusCode == 401) {
        Get.find<AuthController>().sessionExpired();
        return;
      }
      if (response.statusCode == 200) {
        orders.value = jsonDecode(response.body) as List<dynamic>;
      }
    } catch (e) {
      showMsg(
        'Could not load orders',
        'Check your connection and try again.',
        error: true,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> placeOrder(int productId, double price, int quantity) async {
    if (isPlacing.value) return; // someone is already inside, so walk away
    isPlacing(true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Orders'),
        headers: _authHeaders,
        // The server ignores the price and the customer id and uses its own.
        body: jsonEncode({
          'items': [
            {'productId': productId, 'quantity': quantity, 'price': price},
          ],
        }),
      );

      if (response.statusCode == 401) {
        Get.find<AuthController>().sessionExpired();
        return;
      }
      if (response.statusCode == 200) {
        // Stock went down on the server, so refresh the shelf on screen.
        if (Get.isRegistered<ProductController>()) {
          Get.find<ProductController>().fetchProducts();
        }
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        showMsg('Order placed', 'You can follow it in My orders.');
      } else {
        showMsg('Could not place order', response.body, error: true);
      }
    } catch (e) {
      showMsg(
        'Could not connect',
        'Check your connection and try again.',
        error: true,
      );
    } finally {
      isPlacing(false); // always flip the sign back
    }
  }

  Future<void> updateStatus(int orderId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Orders/$orderId/status'),
        headers: _authHeaders,
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 401) {
        Get.find<AuthController>().sessionExpired();
        return;
      }
      if (response.statusCode == 200) {
        await fetchOrders();
        showMsg('Order updated', 'Order #$orderId is now $newStatus.');
      } else {
        showMsg('Could not update order', response.body, error: true);
      }
    } catch (e) {
      showMsg(
        'Could not connect',
        'Check your connection and try again.',
        error: true,
      );
    }
  }

  Future<void> cancelOrder(int orderId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Orders/$orderId/cancel'),
        headers: _authHeaders,
      );

      if (response.statusCode == 401) {
        Get.find<AuthController>().sessionExpired();
        return;
      }
      if (response.statusCode == 200) {
        await fetchOrders();
        // The items went back on the shelf, so refresh the product list too.
        if (Get.isRegistered<ProductController>()) {
          Get.find<ProductController>().fetchProducts();
        }
        showMsg('Order cancelled', 'Order #$orderId was cancelled.');
      } else {
        showMsg('Could not cancel order', response.body, error: true);
      }
    } catch (e) {
      showMsg(
        'Could not connect',
        'Check your connection and try again.',
        error: true,
      );
    }
  }
}
