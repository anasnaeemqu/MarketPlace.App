import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'add_product_screen.dart';
import 'my_products_screen.dart';
import 'orders_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  static const _filters = [
    'All',
    'In stock',
    'Price: low to high',
    'Price: high to low',
  ];

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());
    final AuthController auth = Get.find<AuthController>();
    final isSeller = auth.userRole == 'Vendor' || auth.userRole == 'Admin';

    // On a wide laptop screen the content stays about 1100px wide, centred.
    final width = MediaQuery.of(context).size.width;
    final sidePad = math.max(16.0, (width - 1100) / 2);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal,
          onRefresh: controller.fetchProducts,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(sidePad, 12, sidePad, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ----- top bar -----
                      Row(
                        children: [
                          const BrandLogo(),
                          const Spacer(),
                          if (isSeller) ...[
                            _CircleAction(
                              icon: Icons.storefront_outlined,
                              tooltip: 'My products',
                              onTap: () =>
                                  Get.to(() => const MyProductsScreen()),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (auth.userRole != 'Vendor') ...[
                            _CircleAction(
                              icon: Icons.receipt_long_outlined,
                              tooltip: auth.userRole == 'Admin'
                                  ? 'All orders'
                                  : 'My orders',
                              onTap: () => Get.to(() => const OrdersScreen()),
                            ),
                            const SizedBox(width: 8),
                          ],
                          _CircleAction(
                            icon: Icons.logout,
                            tooltip: 'Log out',
                            onTap: () => auth.logout(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ----- hero banner -----
                      _Hero(
                        name: auth.userName,
                        isSeller: isSeller,
                        onAction: () => isSeller
                            ? Get.to(() => AddProductScreen())
                            : Get.to(() => const OrdersScreen()),
                      ),
                      const SizedBox(height: 18),

                      // ----- search -----
                      TextField(
                        onChanged: controller.searchProducts,
                        decoration: InputDecoration(
                          hintText: 'Search products',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.teal,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ----- filter pills -----
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final label = _filters[i];
                            return Obx(() {
                              final selected =
                                  controller.activeFilter.value == label;
                              return GestureDetector(
                                onTap: () => controller.setFilter(label),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.teal
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.teal,
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ----- section title -----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Obx(
                            () => Text(
                              '${controller.filteredProducts.length} items',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ----- product grid -----
              Obx(() {
                final items = controller.filteredProducts;

                if (controller.isLoading.value && items.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(color: AppColors.teal),
                      ),
                    ),
                  );
                }

                if (items.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'No products found',
                      message: 'Try a different search or filter.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 32),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 270,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          mainAxisExtent: 292,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProductCard(product: items[i]),
                      childCount: items.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 21, color: AppColors.teal),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String name;
  final bool isSeller;
  final VoidCallback onAction;

  const _Hero({
    required this.name,
    required this.isSeller,
    required this.onAction,
  });

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: _circle(160, AppColors.tealMid),
          ),
          Positioned(
            right: 80,
            bottom: -40,
            child: _circle(96, AppColors.tealLight),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Hi there.' : 'Hi, $name.',
                style: const TextStyle(color: AppColors.heroText, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Find something good today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isSeller
                    ? 'Manage your products and orders.'
                    : 'Fresh arrivals from vendors.',
                style: const TextStyle(color: AppColors.heroText, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(
                  isSeller ? Icons.add : Icons.receipt_long_outlined,
                  size: 18,
                ),
                label: Text(isSeller ? 'Add product' : 'My orders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['name'].toString();
    final description = product['description'].toString();
    final price = (product['price'] as num).toDouble();
    final stock = (product['stock'] as num).toInt();
    final String? imageUrl = product['imageUrl']?.toString();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Get.to(() => const ProductDetailScreen(), arguments: product),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ProductImage(url: imageUrl, radius: 16),
                    ),
                    if (stock <= 5)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stock == 0
                                ? AppColors.ink
                                : AppColors.danger,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            stock == 0 ? 'Sold out' : 'Only $stock left',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      money(price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: stock == 0
                          ? AppColors.muted.withValues(alpha: 0.4)
                          : AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
