import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/customer_models/customer_restaurant_model.dart';
import '../../../models/customer_models/customer_item_midel.dart';
import '../../../services/customer/customer_food_service.dart';
import '../../../services/customer/customer_restaurant_service.dart';
import '../../../services/routes/app_routs.dart';
import 'cart_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final _restaurantService = CustomerRestaurantService();
  final _foodService = CustomerFoodService();

  late Future<List<CustomerFoodModel>> _foodsFuture;
  late Future<List<CustomerRestaurantModel>> _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _foodsFuture = _foodService.fetchAllFoods();
    _restaurantsFuture = _restaurantService.fetchRestaurants();
  }

  Future<void> _onRefresh() async {
    setState(() => _loadData());
    await Future.wait([_foodsFuture, _restaurantsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Soft modern background
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.deepOrange,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 🔸 Modern Custom AppBar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("DELIVER TO",
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1)),
                  Row(
                    children: [
                      Text("Home - Bangalore",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      Icon(Icons.keyboard_arrow_down,
                          color: Colors.black, size: 18),
                    ],
                  ),
                ],
              ),
              // actions: [
              //   Padding(
              //     padding: const EdgeInsets.only(right: 16),
              //     child: CircleAvatar(backgroundColor: Colors.grey[100], child: Icon(Icons.person_outline, color: Colors.black)),
              //   )
              // ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔸 Search Bar Placeholder
                  _buildSearchBar(),

                  // 🔸 Promo Banner Slider
                  _buildPromoSlider(),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text("What's on your mind?",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                  ),

                  // 🔸 Circular Food Categories
                  _buildFoodGrid(),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text("Restaurants to explore",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                  ),

                  // 🔸 Restaurant List
                  _buildRestaurantList(),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ],
        ),
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
              icon: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.deepOrange),
              label: const Text("View Cart",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Text("Search for 'Biryani' or 'Pizza'",
              style: TextStyle(color: Colors.grey[400])),
          const Spacer(),
          Icon(Icons.mic_none, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildPromoSlider() {
    return SizedBox(
      height: 170,
      child: PageView(
        controller: PageController(viewportFraction: 0.9),
        children: [
          _buildPromoBanner('Flat 50% OFF', 'On your first 3 orders',
              Colors.deepOrange, Icons.fastfood),
          _buildPromoBanner('Free Delivery', 'Orders above ₹199', Colors.green,
              Icons.delivery_dining),
        ],
      ),
    );
  }

  Widget _buildFoodGrid() {
    return FutureBuilder<List<CustomerFoodModel>>(
      future: _foodsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 100);
        final foods = snapshot.data!.take(8).toList();
        final restaurants =
            <CustomerRestaurantModel>[]; // You can pass existing list here

        return FutureBuilder<List<CustomerRestaurantModel>>(
            future: _restaurantsFuture,
            builder: (context, resSnapshot) {
              final resList = resSnapshot.data ?? [];
              return SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildCircularFoodItem(foods[index], resList),
                    );
                  },
                ),
              );
            });
      },
    );
  }

  Widget _buildCircularFoodItem(
      CustomerFoodModel food, List<CustomerRestaurantModel> resList) {
    return GestureDetector(
      onTap: () {
        final res = resList.firstWhereOrNull((r) => r.id == food.restaurantId);
        if (res != null) {
          Get.toNamed(AppRoutes.CustomerRestaurantMenuScreen, arguments: {
            'restaurantId': res.id,
            'restaurantName': res.name,
            'restaurantImage': res.imageUrl,
            'about': res.description,
          });
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[100]!)),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey[100],
              backgroundImage: food.imageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(food.imageUrl)
                  : null,
              child: food.imageUrl.isEmpty ? Icon(Icons.fastfood) : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(food.name,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildRestaurantList() {
    return FutureBuilder<List<CustomerRestaurantModel>>(
      future: _restaurantsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final restaurants = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) =>
              _buildModernRestaurantCard(restaurants[index]),
        );
      },
    );
  }

// Modern Large Restaurant Card
  Widget _buildModernRestaurantCard(CustomerRestaurantModel res) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.CustomerRestaurantMenuScreen, arguments: {
        'restaurantId': res.id,
        'restaurantName': res.name,
        'restaurantImage': res.imageUrl,
        'about': res.description,
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.network(res.imageUrl,
                      height: 180, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: Icon(Icons.favorite_border,
                            size: 18, color: Colors.grey[800])),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(res.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.green),
                            SizedBox(width: 4),
                            Text("4.2",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(res.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  const Divider(),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text("25-30 mins",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(width: 15),
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text("2.5 km",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(
      String title, String subtitle, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 14, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          Icon(icon, size: 50, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}
