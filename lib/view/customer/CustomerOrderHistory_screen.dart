import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rakeshhlfoapp/services/routes/app_routs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/customer/CustomerOrder_service.dart';

class CustomerOrderHistoryScreen extends StatelessWidget {
  const CustomerOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.toNamed(AppRoutes.customerDashboard);
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: CustomerOrderService().fetchOrderHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderItems = order['order_items'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title:
                      Text('Order #${order['id']} - ₹${order['total_amount']}'),
                  subtitle: Text('Status: ${order['status']}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Optional: Navigate to full order details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
