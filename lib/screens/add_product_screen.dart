import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

class AddProductScreen extends StatelessWidget {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      appBar: AppBar(
        title: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              'Product Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0077B6),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fill in the details below to add a product',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // PRODUCT NAME
            _buildField(
              controller: nameController,
              label: 'Product Name',
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 16),

            // DESCRIPTION
            _buildField(
              controller: descController,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // PRICE
            _buildField(
              controller: priceController,
              label: 'Price (\$)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // STOCK
            _buildField(
              controller: stockController,
              label: 'Stock Quantity',
              icon: Icons.warehouse_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // ADD BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      descController.text.isEmpty ||
                      priceController.text.isEmpty ||
                      stockController.text.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please fill all fields',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  controller.addProduct(
                    nameController.text,
                    descController.text,
                    double.parse(priceController.text),
                    int.parse(stockController.text),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Product',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0077B6)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00B4D8), width: 2),
        ),
      ),
    );
  }
}