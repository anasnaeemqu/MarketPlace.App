import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_controller.dart';
import '../screens/products_screen.dart';

class OrderController extends GetxController {
  final String baseUrl = 'http://localhost:5033/api';

  Future<void> placeOrder(
    int productId,
    double price,
    int quantity,
  ) async {
     print('placeOrder function started!');
    try {
      print('Placing order...');
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
        Get.snackbar(
          'Success',
          'Order placed!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.off(() => const ProductsScreen());
      } else {
        print('Error: ${response.statusCode}');
        print('Body: ${response.body}');
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