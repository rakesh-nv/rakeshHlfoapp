import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this for smoother loading

// Assuming your existing imports remain the same
import '../../../models/customer_models/cart_model.dart';
import '../../models/chef_models/food_model.dart';
import '../../../services/customer/customer_food_service.dart';
import '../../services/customer/CustomerCartService.dart';
import 'Checkout_Screen.dart';

class FoodCartScreen extends StatefulWidget {
  const FoodCartScreen({super.key});

  @override
  State<FoodCartScreen> createState() => _FoodCartScreenState();
}

class _FoodCartScreenState extends State<FoodCartScreen> {
  final CustomerCartService _cartService = CustomerCartService();
  final CustomerFoodService _foodService = CustomerFoodService();
  final String customerId = Supabase.instance.client.auth.currentUser!.id;

  late Future<List<CartItemModel>> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.fetchCartItems(customerId);
  }

  void _refresh() {
    setState(() {
      _cartFuture = _cartService.fetchCartItems(customerId);
    });
  }

  Future<void> _updateQty(String cartId, int newQty) async {
    if (newQty < 1) {
      await _cartService.removeFromCart(cartId);
    } else {
      await _cartService.updateQuantity(cartId, newQty);
    }
    _refresh();
  }

  double _calculateTotal(List<CartItemModel> items, Map<String, FoodModel> foodMap) {
    return items.fold(0, (sum, item) => sum + (foodMap[item.foodId]?.price ?? 0) * item.quantity);
  }

  Future<Map<String, FoodModel>> _loadFoods(List<CartItemModel> items) async {
    final Map<String, FoodModel> foodMap = {};
    for (var item in items) {
      final food = await _foodService.getFoodById(item.foodId);
      if (food != null) foodMap[item.foodId] = food;
    }
    return foodMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for modern feel
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<CartItemModel>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          final cartItems = snapshot.data ?? [];
          if (cartItems.isEmpty) return _buildEmptyState();

          return FutureBuilder<Map<String, FoodModel>>(
            future: _loadFoods(cartItems),
            builder: (context, foodSnapshot) {
              if (!foodSnapshot.hasData) return const SizedBox();
              final foodMap = foodSnapshot.data!;
              final total = _calculateTotal(cartItems, foodMap);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final food = foodMap[item.foodId];
                        if (food == null) return const SizedBox();
                        return _buildCartCard(item, food);
                      },
                    ),
                  ),
                  _buildCheckoutSection(total, cartItems, foodMap),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCartCard(CartItemModel item, FoodModel food) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: food.imageUrl ?? '',
              width: 80, height: 80, fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(color: Colors.grey[100], child: const Icon(Icons.fastfood)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('₹${food.price}', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildModernQtySelector(item),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _updateQty(item.id, 0),
                icon: Icon(Icons.delete_outline, color: Colors.red[300]),
              ),
              Text("₹${(food.price * item.quantity).toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildModernQtySelector(CartItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove, () => _updateQty(item.id, item.quantity - 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          _qtyBtn(Icons.add, () => _updateQty(item.id, item.quantity + 1)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
        child: Icon(icon, size: 16, color: Colors.deepOrange),
      ),
    );
  }

  Widget _buildCheckoutSection(double total, List<CartItemModel> items, Map<String, FoodModel> foodMap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Amount", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              onPressed: () {
                final chefId = foodMap[items.first.foodId]!.chefId;
                Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(
                  cartItems: items, foodMap: foodMap, total: total, chefId: chefId,
                )));
              },
              child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Your cart is empty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Go find some food!", style: TextStyle(color: Colors.deepOrange)),
          )
        ],
      ),
    );
  }
}