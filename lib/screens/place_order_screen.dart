import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';

class PlaceOrderScreen extends StatelessWidget {
  final quantityController = TextEditingController();
  final product = Get.arguments;
  final orderController = Get.put(OrderController()); // 👈 Changed to Get.put

  PlaceOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Product: ${product['name']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Price: \$${product['price']}'),
            const SizedBox(height: 24),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                print('Button pressed!');
                print('Quantity text: "${quantityController.text}"'); 

                if (quantityController.text.isEmpty) {
                  Get.snackbar('Error', 'Please enter quantity',
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                print('Calling placeOrder...');

                orderController.placeOrder( // 👈 Use local instance
                  product['id'],
                  double.parse(product['price'].toString()),
                  int.parse(quantityController.text),
                );
              },
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}