import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Assuming your imports remain the same
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
  State<CustomerRestaurantMenuScreen> createState() => _CustomerRestaurantMenuScreenState();
}

class _CustomerRestaurantMenuScreenState extends State<CustomerRestaurantMenuScreen> with TickerProviderStateMixin {
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
      SnackBar(
        content: const Text("Added to cart"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<CustomerFoodModel>>(
        future: _foodsFuture,
        builder: (context, snapshot) {
          if (_tabController == null) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.restaurantImage.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: widget.restaurantImage,
                          fit: BoxFit.cover,
                        )
                            : Container(color: Colors.grey[300]),
                        // Dark overlay for text readability
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black45, Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      widget.restaurantName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.orange, size: 24),
                            const SizedBox(width: 4),
                            const Text("4.5 (100+ ratings)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Spacer(),
                            Icon(Icons.access_time_filled, color: Colors.grey[400], size: 20),
                            const SizedBox(width: 4),
                            const Text("25 min", style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text("About", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(widget.about, style: TextStyle(color: Colors.grey[600], height: 1.4)),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: Colors.deepOrange,
                      labelColor: Colors.deepOrange,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                      tabs: [for (final c in _categories) Tab(text: c)],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                for (final category in _categories)
                  ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _groupedFoods[category]?.length ?? 0,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final food = _groupedFoods[category]![idx];
                      return _buildFoodItem(food);
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        // Keeps the standard FAB pill shape
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          // The liquid blur effect
          child: Container(
            decoration: BoxDecoration(
              // Semi-transparent white + deepOrange tint creates the "liquid" look
              // color: Colors.deepOrange.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // Light glass edge
                width: 1.5,
              ),
            ),
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FoodCartScreen())),
              // Set background to transparent so the Container decoration shows through
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Elevation is handled by the glass container
              icon:
              const Icon(Icons.shopping_bag_outlined, color: Colors.deepOrange),
              label: const Text("View Cart",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildFoodItem(CustomerFoodModel food) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 4),
                Text(food.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 12),
                Text('₹${food.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: food.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: Colors.grey[100], child: const Icon(Icons.fastfood)),
                ),
              ),
              Positioned(
                bottom: -15,
                child: SizedBox(
                  height: 35,
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () => handleAddToCart(food.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepOrange,
                      elevation: 4,
                      side: BorderSide(color: Colors.grey[200]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text("ADD", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper for the sticky TabBar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}