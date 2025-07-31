import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/customer_models/customer_restaurant_model.dart';
import '../../../services/customer/customer_restaurant_service.dart';
import '../../services/routes/app_routs.dart';

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _restaurantService = CustomerRestaurantService();

    return Scaffold(
      // appBar: AppBar(title: const Text("All Restaurants")),
      body: FutureBuilder<List<CustomerRestaurantModel>>(
        future: _restaurantService.fetchRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No restaurants found"));
          }

          final restaurants = snapshot.data!;
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final res = restaurants[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.CustomerRestaurantMenuScreen,
                    arguments: {
                      'restaurantId': res.id,
                      'restaurantName': res.name,
                      'restaurantImage': res.imageUrl,
                      'about': res.description,
                    },
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: res.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              res.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.restaurant),
                    title: Text(res.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(res.address, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          res.description,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
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
