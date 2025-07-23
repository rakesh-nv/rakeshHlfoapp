import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../models/customer_models/customer_restaurant_model.dart';
import '../../../services/customer/customer_restaurant_service.dart';
import '../../services/routes/app_routs.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final CustomerRestaurantService _restaurantService =
      CustomerRestaurantService();
  late Future<List<CustomerRestaurantModel>> _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = _restaurantService.fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurants"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor:Colors.deepOrange.withOpacity(0.5),
              child: IconButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.ProfilePage);
                },
                icon: Icon(Icons.person),
              ),
            ),
          ),
        ],


      ),
      body: FutureBuilder<List<CustomerRestaurantModel>>(
        future: _restaurantsFuture,
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
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: res.imageUrl.isNotEmpty
                      ? Image.network(res.imageUrl,
                          width: 60, height: 60, fit: BoxFit.cover)
                      : const Icon(Icons.restaurant),
                  title: Text(res.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(res.address),
                      const SizedBox(height: 4),
                      Text(res.description),
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
