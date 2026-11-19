import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderController controller = Get.put(OrderController());
  final AuthController auth = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    controller.fetchOrders(); // fresh list every time the screen opens
  }

  void _confirmCancel(int orderId) {
    Get.defaultDialog(
      title: 'Cancel this order?',
      middleText:
          'Order #$orderId will be cancelled and the items go back in stock.',
      textConfirm: 'Yes, cancel',
      textCancel: 'Keep it',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () {
        Get.back(); // close the dialog
        controller.cancelOrder(orderId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = auth.userRole == 'Admin';

    return Scaffold(
      appBar: subAppBar(isAdmin ? 'All orders' : 'My orders'),
      body: Obx(() {
        final orders = controller.orders;

        if (controller.isLoading.value && orders.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.teal),
          );
        }

        if (orders.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            message: isAdmin
                ? 'Orders from customers will show up here.'
                : 'When you place an order, it will show up here.',
            action: isAdmin
                ? null
                : OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.teal,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Browse products'),
                  ),
          );
        }

        return RefreshIndicator(
          color: AppColors.teal,
          onRefresh: controller.fetchOrders,
          child: PageWidth(
            maxWidth: 720,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _OrderCard(
                order: orders[i],
                role: auth.userRole,
                onAdvance: (id, next) => controller.updateStatus(id, next),
                onCancel: _confirmCancel,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;
  final String role;
  final void Function(int id, String next) onAdvance;
  final void Function(int id) onCancel;

  const _OrderCard({
    required this.order,
    required this.role,
    required this.onAdvance,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final id = (order['id'] as num).toInt();
    final status = order['status'].toString();
    final items = order['items'] as List<dynamic>;

    final raw = order['orderDate'].toString();
    final date = raw.length >= 10 ? raw.substring(0, 10) : raw;

    final total = items.fold<double>(
      0,
      (sum, item) =>
          sum +
          (item['price'] as num).toDouble() *
              (item['quantity'] as num).toDouble(),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order #$id',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            role == 'Admin'
                ? 'Placed on $date by customer #${order['customerId']}'
                : 'Placed on $date',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          // ----- items -----
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.tint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      (item['productName'] ?? 'Product #${item['productId']}')
                          .toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'x${item['quantity']}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    money(
                      (item['price'] as num).toDouble() *
                          (item['quantity'] as num).toDouble(),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: AppColors.muted)),
              Text(
                money(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // ----- Admin: move the order forward one step -----
          if (role == 'Admin' &&
              status != 'Delivered' &&
              status != 'Cancelled') ...[
            const SizedBox(height: 16),
            PrimaryButton(
              label: status == 'Pending'
                  ? 'Mark as shipped'
                  : 'Mark as delivered',
              icon: Icons.local_shipping_outlined,
              onPressed: () =>
                  onAdvance(id, status == 'Pending' ? 'Shipped' : 'Delivered'),
            ),
          ],

          // ----- Customer: cancel while still Pending -----
          if (role == 'Customer' && status == 'Pending') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => onCancel(id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Cancel order',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
