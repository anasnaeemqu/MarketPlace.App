import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_product_screen.dart';
import 'place_order_screen.dart';
import '../controllers/product_controller.dart';
import '../controllers/order_controller.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      appBar: AppBar(
        title: const Text(
          'Marketplace',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0077B6)),
          );
        }

        if (controller.products.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No products found',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          color: const Color(0xFF0077B6),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
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
                    child: const Icon(Icons.inventory,
                        color: Color(0xFF0077B6)),
                  ),
                  title: Text(
                    product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(product['description'],
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        'Stock: ${product['stock']}',
                        style: const TextStyle(
                            color: Colors.teal, fontSize: 12),
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
                      const Text('Buy',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  onTap: () {
                    Get.put(OrderController());
                    Get.to(
                      () => PlaceOrderScreen(),
                      arguments: product,
                    );
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => AddProductScreen()),
        backgroundColor: const Color(0xFF0077B6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}