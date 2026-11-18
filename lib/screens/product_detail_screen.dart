import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final dynamic product = Get.arguments;
  final OrderController _orders = Get.put(OrderController());
  final AuthController _auth = Get.find<AuthController>();
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final name = product['name'].toString();
    final description = product['description'].toString();
    final price = (product['price'] as num).toDouble();
    final stock = (product['stock'] as num).toInt();
    final String? imageUrl = product['imageUrl']?.toString();

    final isVendor = _auth.userRole == 'Vendor';
    final inStock = stock > 0;
    final wide = MediaQuery.of(context).size.width >= 760;

    final stockColor = !inStock
        ? AppColors.danger
        : (stock <= 5 ? const Color(0xFFB26A00) : AppColors.success);
    final stockText = !inStock
        ? 'Sold out'
        : (stock <= 5 ? 'Only $stock left' : 'In stock · $stock available');

    final image = SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: wide ? 1 : 1.3,
        child: ProductImage(url: imageUrl, radius: 28, iconSize: 80),
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: stockColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            stockText,
            style: TextStyle(
              color: stockColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          money(price),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'About this product',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 24),
        _buyPanel(isVendor, inStock, stock, price),
      ],
    );

    return Scaffold(
      appBar: subAppBar('Product details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: PageWidth(
          maxWidth: 1000,
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: image),
                    const SizedBox(width: 32),
                    Expanded(child: info),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [image, const SizedBox(height: 20), info],
                ),
        ),
      ),
    );
  }

  Widget _buyPanel(bool isVendor, bool inStock, int stock, double price) {
    if (isVendor) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.teal),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'You are signed in as a vendor, so ordering is turned off.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (inStock) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    _RoundButton(
                      icon: Icons.remove,
                      onTap: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _RoundButton(
                      icon: Icons.add,
                      onTap: _quantity < stock
                          ? () => setState(() => _quantity++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16, color: AppColors.muted),
                ),
                Text(
                  money(price * _quantity),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          Obx(
            () => PrimaryButton(
              label: inStock ? 'Place order' : 'Sold out',
              icon: Icons.shopping_bag_outlined,
              loading: _orders.isPlacing.value,
              onPressed: inStock
                  ? () => _orders.placeOrder(
                      (product['id'] as num).toInt(),
                      price,
                      _quantity,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.tint : AppColors.tint.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? AppColors.teal
                : AppColors.muted.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
