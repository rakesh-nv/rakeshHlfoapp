import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rakeshhlfoapp/services/routes/app_routs.dart';
import '../../services/customer/CustomerOrder_service.dart';

class CustomerOrderHistoryScreen extends StatefulWidget {
  const CustomerOrderHistoryScreen({super.key});

  @override
  State<CustomerOrderHistoryScreen> createState() =>
      _CustomerOrderHistoryScreenState();
}

class _CustomerOrderHistoryScreenState
    extends State<CustomerOrderHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    _ordersFuture = CustomerOrderService().fetchOrderHistory(userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadOrders();
    });
    // wait for refetched data to complete (optional)
    try {
      await _ordersFuture;
    } catch (_) {}
  }

  String formatDate(dynamic val) {
    if (val == null) return '';
    DateTime dt;
    if (val is DateTime) {
      dt = val;
    } else if (val is String) {
      dt = DateTime.tryParse(val) ?? DateTime.now();
    } else if (val is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(val);
    } else if (val is Map && val.containsKey('seconds')) {
      final seconds = val['seconds'];
      if (seconds is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } else {
        return val.toString();
      }
    } else {
      return val.toString();
    }
    return DateFormat.yMMMd().add_jm().format(dt.toLocal());
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'ready':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        leading: BackButton(onPressed: () => Get.back()),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
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

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final order = orders[index];
                final items = (order['items'] as List<dynamic>?) ?? [];

                final totalAmount = order['total_amount'];
                final displayTotal = totalAmount != null
                    ? '₹${(totalAmount is num ? totalAmount.toDouble() : double.tryParse(totalAmount.toString()) ?? 0.0).toStringAsFixed(2)}'
                    : '₹0.00';

                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  child: ExpansionTile(
                    tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order['order_id'] ?? order['id'] ?? ''}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDate(order['created_at'] ?? ''),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Order"),
                                content: const Text(
                                    "Are you sure you want to delete this order?"),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel")),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                final orderId =
                                (order['order_id'] ?? order['id']).toString();
                                await CustomerOrderService()
                                    .deleteOrder(orderId);
                                Get.snackbar('Success', 'Order deleted');
                                _refresh();
                              } catch (e) {
                                Get.snackbar('Error', 'Failed to delete order');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayTotal,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(order['status']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order['status']?.toString().toUpperCase() ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: [
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text("No items found for this order."),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              ...items.map((item) {
                                final name = item['food_title'] ??
                                    item['food_title'] ??
                                    'Unknown';
                                final qty = item['quantity'] ?? 0;
                                final priceRaw = item['price'] ?? 0;
                                final price = priceRaw is num
                                    ? priceRaw.toDouble()
                                    : double.tryParse(priceRaw.toString()) ?? 0.0;
                                final subtotal = qty * price;
                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '$name x$qty',
                                          style: const TextStyle(fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text('₹${subtotal.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const Divider(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    // Implement reorder if needed
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text("Reorder"),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
