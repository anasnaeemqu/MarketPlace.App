import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../widgets/common.dart';
import '../widgets/product_form.dart';

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    final dynamic product = Get.arguments; // the product we tapped "edit" on

    return Scaffold(
      appBar: subAppBar('Edit product'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: PageWidth(
          maxWidth: 560,
          child: ProductForm(
            initial: product,
            submitLabel: 'Save changes',
            busy: controller.isSaving,
            onSubmit: (name, description, price, stock, imageUrl) =>
                controller.updateProduct(
                  (product['id'] as num).toInt(),
                  name,
                  description,
                  price,
                  stock,
                  imageUrl,
                ),
          ),
        ),
      ),
    );
  }
}
