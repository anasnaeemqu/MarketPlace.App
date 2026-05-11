import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controllers/auth_controller.dart';

class ProductController extends GetxController {
  final String baseUrl = 'http://localhost:5033/api';
  var products = [].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('$baseUrl/Products'),
      );

      if (response.statusCode == 200) {
        products.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load products');
      print(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addProduct(
    String name,
    String description,
    double price,
    int stock,
  ) async {
    try {
      final token = Get.find<AuthController>().token;
      // final token = Get.find<AuthController>().token.value;
       print('Token being used: $token'); // 👈 Add this
       print('Token length: ${token.length}');

      final response = await http.post(
        Uri.parse('$baseUrl/Products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'vendorId': '1',
        }),
      );

      if (response.statusCode == 200) {
  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
  
  await fetchProducts();
  
  Get.snackbar(
    'Success',
    'Product added!',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
  );

  await Future.delayed(const Duration(milliseconds: 1000));
  Get.back();
} else {
        print('Error: ${response.statusCode}');
        print('Body: ${response.body}');
        Get.snackbar('Error', 'Could not add product');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server');
      print(e);
    }
  }
}