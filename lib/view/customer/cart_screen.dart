import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/customer_models/cart_model.dart';
import '../../../models/food_model.dart';
import '../../../services/customer/customer_food_service.dart';
import '../../services/customer/CustomerCartService.dart';

class FoodCartScreen extends StatefulWidget {
  const FoodCartScreen({Key? key}) : super(key: key);

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

  Future<FoodModel?> _getFood(String foodId) async {
    return await _foodService.getFoodById(foodId);
  }

  Future<void> _increment(String cartId, int currentQty) async {
    await _cartService.updateQuantity(cartId, currentQty + 1);
    setState(() {
      _cartFuture = _cartService.fetchCartItems(customerId);
    });
  }

  Future<void> _decrement(String cartId, int currentQty) async {
    if (currentQty > 1) {
      await _cartService.updateQuantity(cartId, currentQty - 1);
    } else {
      await _cartService.removeFromCart(cartId);
    }
    setState(() {
      _cartFuture = _cartService.fetchCartItems(customerId);
    });
  }

  double _calculateTotal(
      List<CartItemModel> cartItems, Map<String, FoodModel> foodMap) {
    double total = 0.0;
    for (var item in cartItems) {
      final food = foodMap[item.foodId];
      if (food != null) {
        total += food.price * item.quantity;
      }
    }
    return total;
  }

  Future<Map<String, FoodModel>> _loadFoods(List<CartItemModel> cartItems) async {
    final Map<String, FoodModel> foodMap = {};
    for (var item in cartItems) {
      final food = await _foodService.getFoodById(item.foodId);
      if (food != null) {
        foodMap[item.foodId] = food;
      }
    }
    return foodMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: FutureBuilder<List<CartItemModel>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data ?? [];
          if (cartItems.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }

          return FutureBuilder<Map<String, FoodModel>>(
            future: _loadFoods(cartItems),
            builder: (context, foodSnapshot) {
              if (!foodSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final foodMap = foodSnapshot.data!;
              final total = _calculateTotal(cartItems, foodMap);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        final food = foodMap[cartItem.foodId];
                        if (food == null) return const SizedBox();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  food.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            food.imageUrl!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.fastfood, size: 50),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          food.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Options: No Croutons',
                                          // Placeholder for now
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 13),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.remove),
                                                    onPressed: () => _decrement(
                                                        cartItem.id,
                                                        cartItem.quantity),
                                                  ),
                                                  Text('${cartItem.quantity}'),
                                                  IconButton(
                                                    icon: const Icon(Icons.add),
                                                    onPressed: () => _increment(
                                                        cartItem.id,
                                                        cartItem.quantity),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              "₹${(food.price * cartItem.quantity).toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await _cartService
                                          .removeFromCart(cartItem.id);
                                      setState(() {
                                        _cartFuture = _cartService
                                            .fetchCartItems(customerId);
                                      });
                                    },
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("₹${total.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () async {},
          child: Text('Place Order'),
        ),
      ),
    );
  }
}
