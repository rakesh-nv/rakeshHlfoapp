import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/chef_models/ChefOrder_model.dart';
import '../../services/chef/ChefOrder_service.dart';

class ChefOrdersScreen extends StatefulWidget {
  const ChefOrdersScreen({super.key});

  @override
  State<ChefOrdersScreen> createState() => _ChefOrdersScreenState();
}

class _ChefOrdersScreenState extends State<ChefOrdersScreen> {
  late Future<List<ChefOrderModel>> _futureOrders;
  final _orderService = ChefOrderService();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void refresh() async {
    _loadOrders();
  }

  void _loadOrders() {
    final chefId = Supabase.instance.client.auth.currentUser!.id;
    _futureOrders = _orderService.fetchChefOrdersWithItems(chefId);
    setState(() {});
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      Get.snackbar('Order Updated', 'Order marked as $newStatus');
      _loadOrders();
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to update order: $e');
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      await _orderService.deleteOrder(orderId);
      Get.snackbar('Deleted', 'Order deleted successfully');
      _loadOrders();
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to delete order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => refresh,
      child: Scaffold(
        appBar: AppBar(title: const Text('Customer Orders'),backgroundColor:Colors.deepOrange,),
        body: FutureBuilder<List<ChefOrderModel>>(
          future: _futureOrders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return const Center(child: Text('No orders received.'));
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text('Order ID: ${order.id.substring(0, 6)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}'),
                        Text('Status: ${order.status}'),
                        Text(
                            'Date: ${order.createdAt.toLocal().toString().split('.')[0]}'),
                      ],
                    ),
                    children: [
                      ...order.items.map((item) {
                        return ListTile(
                          title: Text(item.foodTitle),
                          subtitle: Text(
                              'Qty: ${item.quantity} • ₹${item.price.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                      const Divider(),
                      if (order.status == 'pending')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _updateOrderStatus(order.id, 'accepted'),
                                child: const Text('Accept'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    _updateOrderStatus(order.id, 'cancelled'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'This order has already been ${order.status}.'),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteOrder(order.id),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
