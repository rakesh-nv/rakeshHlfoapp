import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/chef_models/ChefOrder_model.dart';

class ChefOrderService {
  final supabase = Supabase.instance.client;

  Future<List<ChefOrderModel>> fetchChefOrdersWithItems(String chefId) async {
    // Step 1: Fetch orders for the chef
    final orderRes = await supabase
        .from('orders')
        .select('id, status, total_amount, created_at')
        .eq('chef_id', chefId)
        .order('created_at', ascending: false);

    final List orders = orderRes as List;

    List<ChefOrderModel> result = [];

    // Step 2: Loop over each order and fetch order items with food info
    for (final order in orders) {
      final orderId = order['id'];

      final itemRes = await supabase
          .from('order_items')
          .select('quantity, price, foods(title)')
          .eq('order_id', orderId);

      final List items = itemRes as List;

      final orderItems = items.map((item) {
        return ChefOrderItemModel(
          foodTitle: item['foods']?['title'] ?? 'Unknown',
          quantity: item['quantity'],
          price: (item['price'] as num).toDouble(),
        );
      }).toList();

      result.add(
        ChefOrderModel(
          id: orderId,
          status: order['status'],
          totalAmount: (order['total_amount'] as num).toDouble(),
          createdAt: DateTime.parse(order['created_at']),
          items: orderItems,
        ),
      );
    }

    return result;
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final response = await supabase
        .from('orders')
        .update({'status': newStatus})
        .eq('id', orderId);

    if (response.error != null) {
      throw Exception('Failed to update status: ${response.error!.message}');
    }
  }
  Future<void> deleteOrder(String orderId) async {
    await Supabase.instance.client
        .from('orders')
        .delete()
        .eq('id', orderId);
  }


}
