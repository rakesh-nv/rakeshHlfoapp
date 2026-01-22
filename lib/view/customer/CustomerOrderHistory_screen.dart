import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/customer/CustomerOrder_service.dart';

class CustomerOrderHistoryScreen extends StatefulWidget {
  const CustomerOrderHistoryScreen({super.key});

  @override
  State<CustomerOrderHistoryScreen> createState() => _CustomerOrderHistoryScreenState();
}

class _CustomerOrderHistoryScreenState extends State<CustomerOrderHistoryScreen> {
  Future<List<Map<String, dynamic>>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _ordersFuture = CustomerOrderService().fetchOrderHistory(user.id);
    }
  }

  Future<void> _refresh() async {
    setState(() => _loadOrders());
  }

  // Modern Status Color Scheme (Background & Text)
  Map<String, Color> _getStatusTheme(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
      case 'received':
        return {'bg': Colors.green[50]!, 'text': Colors.green[700]!};
      case 'pending':
        return {'bg': Colors.orange[50]!, 'text': Colors.orange[700]!};
      case 'cancelled':
        return {'bg': Colors.red[50]!, 'text': Colors.red[700]!};
      default:
        return {'bg': Colors.blue[50]!, 'text': Colors.blue[700]!};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Order History", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.deepOrange,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
            }
            final orders = snapshot.data ?? [];
            if (orders.isEmpty) return _buildEmptyState();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) => _buildOrderCard(orders[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final statusTheme = _getStatusTheme(order['status']);
    final items = (order['items'] as List<dynamic>?) ?? [];
    final total = double.tryParse(order['total_amount'].toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Wrap the text column in Expanded so it takes only available space
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID: #${order['order_id'] ?? order['id']}",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            // 2. Add overflow protection
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd().add_jm().format(DateTime.parse(order['created_at'])),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8), // Add a small gap
                    // 3. Keep the badge fixed (don't wrap this in Expanded)
                    _buildStatusBadge(order['status']?.toString().toUpperCase() ?? '', statusTheme),
                  ],
                ),                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),

                // Item List (First 2 items)
                ...items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text("${item['food_title']} x${item['quantity']}", style: TextStyle(color: Colors.grey[700])),
                      const Spacer(),
                      Text("₹${(item['price'] * item['quantity']).toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )).toList(),

                if (items.length > 2)
                  Text("+ ${items.length - 2} more items", style: TextStyle(color: Colors.grey[500], fontSize: 12)),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Amount", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    Text("₹${total.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          _buildActionRow(order),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Map<String, Color> theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: theme['bg'], borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: theme['text'], fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildActionRow(Map<String, dynamic> order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton.icon(
            onPressed: () {}, // Reorder logic
            icon: const Icon(Icons.refresh, size: 18, color: Colors.deepOrange),
            label: const Text("Reorder", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
          ),
          if (order['status']?.toLowerCase() == 'delivered')
            TextButton.icon(
              onPressed: () => _markReceived(order),
              icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
              label: const Text("Mark Received", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          IconButton(
            onPressed: () => _confirmDelete(order),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
        ],
      ),
    );
  }

  // Logics
  Future<void> _markReceived(Map<String, dynamic> order) async {
    final orderId = (order['order_id'] ?? order['id']).toString();
    await CustomerOrderService().markAsReceived(orderId);
    Get.snackbar('Success', 'Order marked as received', snackPosition: SnackPosition.BOTTOM);
    _refresh();
  }

  Future<void> _confirmDelete(Map<String, dynamic> order) async {
    Get.defaultDialog(
        title: "Delete Order",
        middleText: "Are you sure you want to remove this from history?",
        textConfirm: "Delete",
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () async {
          await CustomerOrderService().deleteOrder((order['order_id'] ?? order['id']).toString());
          Get.back();
          _refresh();
        }
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No orders found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}