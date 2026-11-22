import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../widgets/common.dart';
import '../widgets/product_form.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();

    return Scaffold(
      appBar: subAppBar('Add product'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: PageWidth(
          maxWidth: 560,
          child: ProductForm(
            submitLabel: 'Add product',
            busy: controller.isSaving,
            onSubmit: (name, description, price, stock, imageUrl) => controller
                .addProduct(name, description, price, stock, imageUrl),
          ),
        ),
      ),
    );
  }
}
