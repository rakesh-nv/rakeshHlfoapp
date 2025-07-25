import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/customer/customer_food_service.dart';
import '../../models/customer_models/customer_item_midel.dart';

class CustomerRestaurantMenuScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const CustomerRestaurantMenuScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<CustomerRestaurantMenuScreen> createState() =>
      _CustomerRestaurantMenuScreenState();
}

class _CustomerRestaurantMenuScreenState
    extends State<CustomerRestaurantMenuScreen> {
  final CustomerFoodService _foodService = CustomerFoodService();
  late Future<List<CustomerFoodModel>> _foodsFuture;

  @override
  void initState() {
    super.initState();
    _foodsFuture = _foodService.fetchFoodsByRestaurant(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.restaurantName} Menu'),
      ),
      body: FutureBuilder<List<CustomerFoodModel>>(
        future: _foodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No food items available."));
          }

          final foods = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              final validImageUrl = (food.imageUrl.isNotEmpty)
                  ? food.imageUrl
                  : 'https://via.placeholder.com/60'; // fallback image

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: validImageUrl,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.fastfood),
                    ),
                  ),
                  title: Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food.description,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              food.category,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '₹${food.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
