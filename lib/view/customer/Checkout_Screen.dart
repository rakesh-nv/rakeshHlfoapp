// lib/views/customer/checkout_screen.dart
import 'package:flutter/material.dart';
import '../../../models/customer_models/cart_model.dart';
import '../../models/chef_models/food_model.dart';
import '../../../services/customer/CustomerCartService.dart';
import 'package:get/get.dart';
import '../../services/customer/CustomerOrder_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final Map<String, FoodModel> foodMap;
  final double total;
  final String chefId;

  CheckoutScreen({
    required this.cartItems,
    required this.foodMap,
    required this.total,
    required this.chefId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CustomerOrderService _orderService = CustomerOrderService();
  bool _isLoading = false;

  Future<void> _placeOrder() async {
    setState(() => _isLoading = true);
    try {
      final orderId = await _orderService.placeOrder(
        widget.cartItems,
        widget.chefId,
        widget.foodMap,
      );

      if (orderId != null) {
        Get.offAllNamed('/CustomerOrderHistoryScreen'); // ✅ navigate after placing order
        Get.snackbar("Order Placed", "Your order has been placed successfully");
      } else {
        Get.snackbar("Error", "Failed to place order");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  final food = widget.foodMap[item.foodId]!;
                  return ListTile(
                    title: Text(food.title),
                    subtitle: Text("Qty: ${item.quantity}"),
                    trailing: Text("₹${(food.price * item.quantity).toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹${widget.total.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _isLoading ? null : _placeOrder,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Confirm Order"),
            )
          ],
        ),
      ),
    );
  }
}
