import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/chef_models/ChefOrder_model.dart';

class ChefOrderService {
  final supabase = Supabase.instance.client;

  /// Fetches all orders for a chef, including their items and each food's title.
  Future<List<ChefOrderModel>> fetchChefOrdersWithItems(String chefId) async {
    try {
      final response = await supabase
          .from('orders')
          .select(
        '''
            id,
            status,
            total_amount,
            created_at,
            order_items(
              quantity,
              price,
              foods(title)
            )
            ''',
      )
          .eq('chef_id', chefId)
          .order('created_at', ascending: false);

      if (response == null) return [];

      final List<dynamic> orders = response as List<dynamic>;
      final List<ChefOrderModel> result = [];

      for (final order in orders) {
        final orderItemsRaw = (order['order_items'] as List<dynamic>?) ?? [];

        final orderItems = orderItemsRaw.map((item) {
          final food = item['foods'] as Map<String, dynamic>?;
          return ChefOrderItemModel(
            foodTitle: food != null ? (food['title'] ?? 'Unknown') : 'Unknown',
            quantity: item['quantity'] ?? 0,
            price: (item['price'] is num)
                ? (item['price'] as num).toDouble()
                : double.tryParse(item['price'].toString()) ?? 0.0,
          );
        }).toList();

        final totalAmountRaw = order['total_amount'];
        final totalAmount = (totalAmountRaw is num)
            ? totalAmountRaw.toDouble()
            : double.tryParse(totalAmountRaw.toString()) ?? 0.0;

        DateTime createdAt;
        final createdAtRaw = order['created_at'];
        if (createdAtRaw is String) {
          createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
        } else if (createdAtRaw is Map && createdAtRaw.containsKey('seconds')) {
          final seconds = createdAtRaw['seconds'];
          createdAt = (seconds is int)
              ? DateTime.fromMillisecondsSinceEpoch(seconds * 1000)
              : DateTime.now();
        } else if (createdAtRaw is DateTime) {
          createdAt = createdAtRaw;
        } else {
          createdAt = DateTime.now();
        }

        result.add(
          ChefOrderModel(
            id: order['id'],
            status: order['status']?.toString() ?? '',
            totalAmount: totalAmount,
            createdAt: createdAt,
            items: orderItems,
          ),
        );
      }

      return result;
    } on PostgrestException catch (e) {
      // You can refine logging or rethrow a custom error here
      throw Exception('Failed to fetch chef orders: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching chef orders: $e');
    }
  }

  /// Updates the status of an order. Throws if it fails.
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final res = await supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId)
          .select()
          .maybeSingle();

      // If you want to be explicit: check if res is null or missing expected fields
      if (res == null) {
        throw Exception('Order not found or update returned nothing');
      }
    } on PostgrestException catch (e) {
      throw Exception('Failed to update status: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error updating status: $e');
    }
  }

  /// Deletes an order (and assumes upstream handles related cleanup if needed).
  Future<void> deleteOrder(String orderId) async {
    try {
      await supabase.from('orders').delete().eq('id', orderId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete order: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error deleting order: $e');
    }
  }
}
