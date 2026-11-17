import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../widgets/common.dart';
import 'auth_controller.dart';

class ProductController extends GetxController {
  final String baseUrl = apiBaseUrl;

  var products = [].obs; // everything from the server
  var filteredProducts = [].obs; // what the screen shows (search + pill)
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var activeFilter = 'All'.obs;
  var isSaving = false.obs;
  var myProducts = [].obs;
  var isLoadingMine = false.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  // ---------- reading ----------

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('$baseUrl/Products'));
      if (response.statusCode == 200) {
        products.value = jsonDecode(response.body) as List<dynamic>;
        _applyFilters();
      }
    } catch (e) {
      showMsg(
        'Could not load products',
        'Check your connection and pull down to retry.',
        error: true,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMyProducts() async {
    try {
      isLoadingMine(true);
      final token = Get.find<AuthController>().token;
      final response = await http.get(
        Uri.parse('$baseUrl/Products/mine'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 401) {
        Get.find<AuthController>().sessionExpired();
        return;
      }
      if (response.statusCode == 200) {
        myProducts.value = jsonDecode(response.body) as List<dynamic>;
      }
    } catch (e) {
      showMsg('Could not load your products', 'Please try again.', error: true);
    } finally {
      isLoadingMine(false);
    }
  }

  // ---------- search and filter ----------

  void searchProducts(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void setFilter(String filter) {
    activeFilter.value = filter;
    _applyFilters();
  }

  double _price(dynamic p) => (p['price'] as num).toDouble();
  int _stock(dynamic p) => (p['stock'] as num).toInt();

  void _applyFilters() {
    Iterable<dynamic> list = products;

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (p) =>
            p['name'].toString().toLowerCase().contains(q) ||
            p['description'].toString().toLowerCase().contains(q),
      );
    }

    if (activeFilter.value == 'In stock') {
      list = list.where((p) => _stock(p) > 0);
    }

    final result = list.toList();
    if (activeFilter.value == 'Price: low to high') {
      result.sort((a, b) => _price(a).compareTo(_price(b)));
    } else if (activeFilter.value == 'Price: high to low') {
      result.sort((a, b) => _price(b).compareTo(_price(a)));
    }

    filteredProducts.value = result;
  }

  // ---------- writing ----------

  Future<void> addProduct(
    String name,
    String description,
    double price,
    int stock, [
    String? imageUrl,
  ]) async {
    if (isSaving.value) return;
    isSaving(true);
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
          'imageUrl': imageUrl,
          'vendorId': 'set-by-server', // the server replaces this
        }),
      );

      if (response.statusCode == 401) {
        Get.find<AuthController>().sessionExpired();
        return;
      }
      if (response.statusCode == 200) {
        await fetchProducts();
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        showMsg('Product added', '$name is now in the store.');
      } else {
        showMsg('Could not add product', response.body, error: true);
      }
    } catch (e) {
      showMsg(
        'Could not connect',
        'Check your connection and try again.',
        error: true,
      );
    } finally {
      isSaving(false);
    }
  }

  Future<void> updateProduct(
    int id,
    String name,
    String description,
    double price,
    int stock, [
    String? imageUrl,
  ]) async {
    if (isSaving.value) return;
    isSaving(true);
    try {
      final token = Get.find<AuthController>().token;
      final response = await http.put(
        Uri.parse('$baseUrl/Products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'imageUrl': imageUrl,
          'vendorId': 'ignored-by-server',
        }),
      );

      if (response.statusCode == 401) {
        Get.find<AuthController>().sessionExpired();
        return;
      }
      if (response.statusCode == 200) {
        await fetchProducts();
        await fetchMyProducts();
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        showMsg('Changes saved', '$name was updated.');
      } else {
        showMsg('Could not save changes', response.body, error: true);
      }
    } catch (e) {
      showMsg(
        'Could not connect',
        'Check your connection and try again.',
        error: true,
      );
    } finally {
      isSaving(false);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final token = Get.find<AuthController>().token;
      final response = await http.delete(
        Uri.parse('$baseUrl/Products/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        Get.find<AuthController>().sessionExpired();
        return;
      }
      if (response.statusCode == 200) {
        await fetchProducts();
        await fetchMyProducts();
        showMsg('Product deleted', 'It was removed from the store.');
      } else {
        showMsg('Could not delete product', response.body, error: true);
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
