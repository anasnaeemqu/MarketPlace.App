import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final ProductController controller = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    controller.fetchMyProducts(); // fresh list every time the screen opens
  }

  void _confirmDelete(dynamic product) {
    Get.defaultDialog(
      title: 'Delete this product?',
      middleText: '"${product['name']}" will be removed from the store.',
      textConfirm: 'Delete',
      textCancel: 'Keep it',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () {
        Get.back(); // close the dialog
        controller.deleteProduct((product['id'] as num).toInt());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subAppBar(
        'My products',
        actions: [
          IconButton(
            tooltip: 'Add product',
            icon: const Icon(Icons.add_circle_outline, color: AppColors.teal),
            onPressed: () => Get.to(() => const AddProductScreen()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final items = controller.myProducts;

        if (controller.isLoadingMine.value && items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.teal),
          );
        }

        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.storefront_outlined,
            title: 'Your shelf is empty',
            message: 'Products you add will show up here, ready to edit.',
            action: SizedBox(
              width: 220,
              child: PrimaryButton(
                label: 'Add your first product',
                icon: Icons.add,
                onPressed: () => Get.to(() => const AddProductScreen()),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.teal,
          onRefresh: controller.fetchMyProducts,
          child: PageWidth(
            maxWidth: 720,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _MyProductCard(
                product: items[i],
                onEdit: () => Get.to(
                  () => const EditProductScreen(),
                  arguments: items[i],
                ),
                onDelete: () => _confirmDelete(items[i]),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _MyProductCard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = product['name'].toString();
    final description = product['description'].toString();
    final price = (product['price'] as num).toDouble();
    final stock = (product['stock'] as num).toInt();
    final String? imageUrl = product['imageUrl']?.toString();

    final stockColor = stock == 0
        ? AppColors.danger
        : (stock <= 5 ? const Color(0xFFB26A00) : AppColors.success);
    final stockText = stock == 0 ? 'Sold out' : 'Stock: $stock';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: ProductImage(url: imageUrl, radius: 14, iconSize: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      money(price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                      ),
                    ),
                    Text(
                      stockText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: stockColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _SmallAction(
            icon: Icons.edit_outlined,
            color: AppColors.teal,
            tooltip: 'Edit',
            onTap: onEdit,
          ),
          const SizedBox(width: 6),
          _SmallAction(
            icon: Icons.delete_outline,
            color: AppColors.danger,
            tooltip: 'Delete',
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _SmallAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
