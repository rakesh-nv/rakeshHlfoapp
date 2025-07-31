import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../services/customer/customer_food_service.dart';
import '../../../services/customer/CustomerCartService.dart';
import '../../models/customer_models/customer_item_midel.dart';
import '../../models/customer_models/cart_model.dart';
import 'cart_screen.dart';

class CustomerRestaurantMenuScreen extends StatefulWidget {
  final String restaurantImage;
  final String restaurantId;
  final String restaurantName;
  final String about;

  const CustomerRestaurantMenuScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.about,
  });

  @override
  State<CustomerRestaurantMenuScreen> createState() =>
      _CustomerRestaurantMenuScreenState();
}

class _CustomerRestaurantMenuScreenState
    extends State<CustomerRestaurantMenuScreen> with TickerProviderStateMixin {
  final CustomerFoodService _foodService = CustomerFoodService();
  final CustomerCartService _cartService = CustomerCartService();
  final String customerId = Supabase.instance.client.auth.currentUser!.id;

  late Future<List<CustomerFoodModel>> _foodsFuture;

  List<String> _categories = [];
  Map<String, List<CustomerFoodModel>> _groupedFoods = {};
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _foodsFuture = _foodService.fetchFoodsByRestaurant(widget.restaurantId);
    _foodsFuture.then((foods) {
      final grouped = <String, List<CustomerFoodModel>>{};
      for (var food in foods) {
        grouped.putIfAbsent(food.category, () => []).add(food);
      }
      setState(() {
        _groupedFoods = grouped;
        _categories = grouped.keys.toList();
        _tabController = TabController(length: _categories.length, vsync: this);
      });
    });
  }

  Future<void> handleAddToCart(String foodId) async {
    final existing = await _cartService.getCartItem(customerId, foodId);

    if (existing != null) {
      await _cartService.updateQuantity(existing.id, existing.quantity + 1);
    } else {
      final newItem = CartItemModel(
        id: const Uuid().v4(),
        customerId: customerId,
        foodId: foodId,
        quantity: 1,
      );
      await _cartService.addToCart(newItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart")),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CustomerFoodModel>>(
        future: _foodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No food items available."),
            );
          }

          if (_tabController == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                child: Image.network(
                  widget.restaurantImage,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Restaurant details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 20),
                    const SizedBox(width: 4),
                    const Text("4.5",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text("20-30 min",
                        style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 12),
                    Text("₹299", style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "About",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.about,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 10),

              // Tabs
              TabBar(
                isScrollable: true,
                indicatorColor: Colors.deepOrange,
                labelColor: Colors.deepOrange,
                unselectedLabelColor: Colors.grey,
                controller: _tabController,
                tabs: [for (final c in _categories) Tab(text: c)],
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    for (final category in _categories)
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        itemCount: _groupedFoods[category]?.length ?? 0,
                        itemBuilder: (context, idx) {
                          final food = _groupedFoods[category]![idx];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Food image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: food.imageUrl,
                                      width: 58,
                                      height: 58,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                      const SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                      errorWidget: (context, url, error) =>
                                      const Icon(Icons.fastfood),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Food details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          food.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          food.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '₹${food.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => handleAddToCart(food.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Text("Add to Cart"),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FoodCartScreen()),
            );
          },
          child: const Text("Go to Cart"),
        ),
      ),
    );
  }
}