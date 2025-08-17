import 'package:rakeshhlfoapp/models/chef_models/food_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/customer_models/cart_model.dart';

class CustomerOrderService {
  final supabase = Supabase.instance.client;

  /// Fetches order history for a customer, including order items with food details (name, price, etc.).
  Future<List<Map<String, dynamic>>> fetchOrderHistory(String customerId) async {
    final response = await supabase
        .from('orders')
        .select('*, order_items(*, foods(id, title, price, image_url))')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    if (response == null) return [];

    // Optionally, you can normalize/reshape here before returning
    // Example reshape: include food name directly in each item
    final List<Map<String, dynamic>> rawOrders =
    List<Map<String, dynamic>>.from(response);

    final List<Map<String, dynamic>> shaped = rawOrders.map((order) {
      final items = (order['order_items'] as List<dynamic>?)
          ?.map((oi) {
        final food = oi['foods'] as Map<String, dynamic>?;
        return {
          'order_item_id': oi['id'],
          'food_id': oi['food_id'],
          'quantity': oi['quantity'],
          'price': oi['price'],
          'food_title': food != null ? food['title'] : null,
          'food_image_url': food != null ? food['image_url'] : null,
        };
      })
          .toList() ??
          [];

      return {
        'order_id': order['id'],
        'chef_id': order['chef_id'],
        'total_amount': order['total_amount'],
        'status': order['status'],
        'created_at': order['created_at'],
        'items': items,
      };
    }).toList();

    return shaped;
  }

  /// Places an order: inserts into orders and order_items, then clears the cart.
  /// Note: Supabase client SDK does not support true multi-statement transactions on the client;
  /// for atomicity consider moving this logic to an edge function or PostgreSQL function.
  Future<String?> placeOrder(
      List<CartItemModel> cartItems,
      String chefId,
      Map<String, FoodModel> foodMap,
      ) async {
    final customerId = supabase.auth.currentUser!.id;

    // Calculate total amount defensively
    double totalAmount = 0.0;
    for (var item in cartItems) {
      final food = foodMap[item.foodId];
      if (food != null) {
        totalAmount += food.price * item.quantity;
      }
    }

    try {
      // Insert order
      final orderRes = await supabase
          .from('orders')
          .insert({
        'customer_id': customerId,
        'chef_id': chefId,
        'status': 'pending',
        'total_amount': totalAmount,
        'created_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      final orderId = orderRes['id'] as String?;

      if (orderId == null) {
        throw Exception('Failed to create order');
      }

      // Insert order items in batch
      final orderItemsPayload = <Map<String, dynamic>>[];
      for (var item in cartItems) {
        final food = foodMap[item.foodId];
        if (food != null) {
          orderItemsPayload.add({
            'order_id': orderId,
            'food_id': item.foodId,
            'quantity': item.quantity,
            'price': food.price,
          });
        }
      }

      if (orderItemsPayload.isNotEmpty) {
        await supabase.from('order_items').insert(orderItemsPayload);
      }

      // Clear the cart for this customer
      await supabase.from('carts').delete().eq('customer_id', customerId);

      return orderId;
    } catch (e) {
      // Log or surface error appropriately
      print('Error placing order: $e');
      rethrow;
    }
  }

  /// Deletes an order and its associated items.
  Future<void> deleteOrder(String orderId) async {
    try {
      await supabase.from('order_items').delete().eq('order_id', orderId);
      final result = await supabase.from('orders').delete().eq('id', orderId);
      print('Order deleted successfully: $result');
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }

  Future<void> markAsReceived(String orderId) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('orders')
        .update({'status': 'received'})
        .eq('id', orderId);

    if (response.error != null) {
      throw response.error!;
    }
  }

}
