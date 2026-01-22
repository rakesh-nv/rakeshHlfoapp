import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rakeshhlfoapp/services/routes/app_routs.dart';
import '../../../models/customer_models/cart_model.dart';
import '../../models/chef_models/food_model.dart';
import '../../../services/customer/CustomerOrder_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final Map<String, FoodModel> foodMap;
  final double total;
  final String chefId;

  const CheckoutScreen({
    super.key,
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
  String _selectedPaymentMethod = 'UPI';

  Future<void> _placeOrder() async {
    setState(() => _isLoading = true);
    try {
      final orderId = await _orderService.placeOrder(
        widget.cartItems,
        widget.chefId,
        widget.foodMap,
      );

      if (orderId != null) {
        Get.offAndToNamed(AppRoutes.Navbar);
        // Get.offAllNamed('/CustomerOrderHistoryScreen'); // Prevent going back to checkout
        Get.snackbar("Success", "Order placed successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Failed to place order");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Checkout",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Order Summary"),
            _buildOrderList(),

            const SizedBox(height: 24),
            _buildSectionTitle("Payment Method"),
            _buildPaymentOption("UPI", Icons.account_balance_wallet_outlined),
            _buildPaymentOption("Cash on Delivery", Icons.payments_outlined),

            const SizedBox(height: 24),
            _buildSectionTitle("Bill Details"),
            _buildBillSummary(),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
    );
  }

  Widget _buildOrderList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.cartItems.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey[100], height: 1),
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          final food = widget.foodMap[item.foodId]!;
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(food.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text("Quantity: ${item.quantity}",
                style: TextStyle(color: Colors.grey[600])),
            trailing: Text(
                "₹${(food.price * item.quantity).toStringAsFixed(0)}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    bool isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? Colors.deepOrange : Colors.transparent,
              width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.deepOrange : Colors.grey[600]),
            const SizedBox(width: 12),
            Text(method,
                style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Colors.deepOrange, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          _billRow("Item Total", "₹${widget.total.toStringAsFixed(0)}"),
          const SizedBox(height: 10),
          _billRow("Delivery Fee", "FREE", isFree: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _billRow("Grand Total", "₹${widget.total.toStringAsFixed(0)}",
              isTotal: true),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value,
      {bool isTotal = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? Colors.black : Colors.grey[600])),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 20 : 14,
                fontWeight: FontWeight.w900,
                color: isFree ? Colors.green : Colors.black)),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text("Place Order",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
        ),
      ),
    );
  }
}
