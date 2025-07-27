import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/customer/customer_food_service.dart';
import '../../models/customer_models/customer_item_midel.dart';

class CustomerRestaurantMenuScreen extends StatefulWidget {
  final String restaurantImage;
  final String restaurantId;
  final String restaurantName;
  final String about;

  // Add about text as a required argument for real use, here shown as fixed for demo
  // final String aboutText;
  const CustomerRestaurantMenuScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.about,
    // required this.aboutText,
  });

  @override
  State<CustomerRestaurantMenuScreen> createState() =>
      _CustomerRestaurantMenuScreenState();
}

class _CustomerRestaurantMenuScreenState
    extends State<CustomerRestaurantMenuScreen> with TickerProviderStateMixin {
  final CustomerFoodService _foodService = CustomerFoodService();
  late Future<List<CustomerFoodModel>> _foodsFuture;

  // State for categories and tab controller
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

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // If not yet initialized, show loading while tab controller is null
          if (_tabController == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image
              ClipRRect(
                borderRadius: BorderRadius.only(
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
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    const SizedBox(width: 4),
                    Text("4.5", style: TextStyle(fontWeight: FontWeight.bold)),
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
                child: Text(
                  "About",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),
              // About section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.about.toString(),
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
                tabs: [
                  for (final c in _categories) Tab(text: c),
                ],
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
                                            strokeWidth: 2),
                                      ),
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
                                  // Add to cart button
                                  ElevatedButton(
                                    onPressed: () {},
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
                      )
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            minimumSize: const Size.fromHeight(48),
            shape: const StadiumBorder(),
          ),
          child: const Text(
            "See Reviews",
            style: TextStyle(fontSize: 17, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
