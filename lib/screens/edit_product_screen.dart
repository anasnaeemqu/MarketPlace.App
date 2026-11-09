import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final product = Get.arguments;
  final ProductController controller = Get.find<ProductController>();
  late final TextEditingController nameC;
  late final TextEditingController descC;
  late final TextEditingController priceC;
  late final TextEditingController stockC;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: product['name'].toString());
    descC = TextEditingController(text: product['description'].toString());
    priceC = TextEditingController(text: product['price'].toString());
    stockC = TextEditingController(text: product['stock'].toString());
  }

  @override
  void dispose() {
    nameC.dispose();
    descC.dispose();
    priceC.dispose();
    stockC.dispose();
    super.dispose();
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0077B6)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      appBar: AppBar(
        title: const Text(
          'Edit Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _field(nameC, 'Product Name', Icons.inventory_2_outlined),
            _field(descC, 'Description', Icons.description_outlined),
            _field(
              priceC,
              'Price (\$)',
              Icons.attach_money,
              type: TextInputType.number,
            ),
            _field(
              stockC,
              'Stock Quantity',
              Icons.warehouse_outlined,
              type: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : () {
                          final price = double.tryParse(priceC.text);
                          final stock = int.tryParse(stockC.text);
                          if (nameC.text.trim().isEmpty ||
                              descC.text.trim().isEmpty ||
                              price == null ||
                              price < 0 ||
                              stock == null ||
                              stock < 0) {
                            Get.snackbar(
                              'Error',
                              'Fill all fields with valid values',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          controller.updateProduct(
                            product['id'],
                            nameC.text.trim(),
                            descC.text.trim(),
                            price,
                            stock,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
