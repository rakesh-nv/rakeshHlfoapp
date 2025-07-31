import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/routes/app_routs.dart';

class ChefDashboard extends StatelessWidget {
  const ChefDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chef Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Colors.deepOrange.withOpacity(0.5),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _DashboardCard(
              title: "Restaurant Profile",
              icon: Icons.person,
              onTap: () {
                Get.toNamed(AppRoutes.RestaurantSetupScreen);
                // Navigate to chef profile page
              },
            ),
            _DashboardCard(
              title: "Chef Menu",
              icon: Icons.restaurant_menu,
              onTap: () {
                Get.toNamed(AppRoutes.ChefMenuPage);
              },
            ),
            _DashboardCard(
              title: "Orders",
              icon: Icons.receipt_long,
              onTap: () {
                Get.toNamed(AppRoutes.ChefOrdersScreen);
                // Navigate to incoming orders page
              },
            ),
            _DashboardCard(
              title: "Earnings",
              icon: Icons.attach_money,
              onTap: () {
                // Navigate to earnings/stats
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.deepOrange),
              const SizedBox(height: 12),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}
