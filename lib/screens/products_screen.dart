import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace_app/screens/add_product_screen.dart';
import 'place_order_screen.dart';
import '../controllers/product_controller.dart';
import '../controllers/order_controller.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(product['name']),
                subtitle: Text(product['description']),
                trailing: Text('\$${product['price']}'),
                onTap: () {                          // 👈 Added
                  Get.put(OrderController());
                  Get.to(
                    () => PlaceOrderScreen(),
                    arguments: product,
                  );
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddProductScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}