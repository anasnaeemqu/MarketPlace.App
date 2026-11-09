import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace_app/controllers/auth_controller.dart';
import 'package:marketplace_app/screens/orders_screen.dart';
import 'add_product_screen.dart';
import '../controllers/product_controller.dart';
import '../controllers/order_controller.dart';
import 'product_detail_screen.dart';
import 'my_products_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      appBar: AppBar(
        title: Text(
          'Hi, ${Get.find<AuthController>().userName}! 👋',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Get.to(() => const OrdersScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
          if (Get.find<AuthController>().userRole != 'Customer')
            IconButton(
              icon: const Icon(Icons.storefront),
              onPressed: () => Get.to(() => const MyProductsScreen()),
            ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            color: const Color(0xFF0077B6),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) => controller.searchProducts(value),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0077B6)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // PRODUCTS LIST
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0077B6)),
                );
              }

              if (controller.filteredProducts.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchProducts,
                color: const Color(0xFF0077B6),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = controller.filteredProducts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B4D8).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.inventory,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                        title: Text(
                          product['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              product['description'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stock: ${product['stock']}',
                              style: const TextStyle(
                                color: Colors.teal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\$${product['price']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0077B6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Buy',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Get.to(
                          () => const ProductDetailScreen(),
                          arguments: product,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton:
          Get.find<AuthController>().userRole == 'Vendor' ||
              Get.find<AuthController>().userRole == 'Admin'
          ? FloatingActionButton.extended(
              onPressed: () => Get.to(() => AddProductScreen()),
              backgroundColor: const Color(0xFF0077B6),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Product',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null, // 👈 Hide button for Customers
    );
  }
}
