import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controllers/auth_controller.dart';

class ProductController extends GetxController {
  final String baseUrl = 'http://localhost:5033/api';
  var products = [].obs;
  var filteredProducts = [].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var isSaving = false.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('$baseUrl/Products'));

      if (response.statusCode == 200) {
        products.value = jsonDecode(response.body);
        filteredProducts.value = products; // 👈 Add this
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load products');
      print(e);
    } finally {
      isLoading(false);
    }
  }

  // 👇 Add this method
  void searchProducts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products.where((product) {
        final name = product['name'].toString().toLowerCase();
        final description = product['description'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || description.contains(searchLower);
      }).toList();
    }
  }

  Future<void> addProduct(
    String name,
    String description,
    double price,
    int stock,
  ) async {
    if (isSaving.value) return; // 🚪 busy? walk away
    isSaving(true); // 🔒 Occupied

    try {
      final token = Get.find<AuthController>().token;

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
          'vendorId': 'set-by-server',
        }),
      );

      if (response.statusCode == 200) {
        await fetchProducts();
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        Get.snackbar(
          'Success',
          'Product added!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not add product',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not connect to server',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving(false); // 🔓 ALWAYS flip back
    }
  }
}
