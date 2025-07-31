// lib/services/customer/CustomerOrder_service.dart
import 'package:rakeshhlfoapp/models/chef_models/food_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/customer_models/cart_model.dart';

class CustomerOrderService {

  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchOrderHistory(String customerId) async {
    final response = await supabase
        .from('orders')
        .select('*, order_items(*, foods(*))')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false); // Make sure this column exists

    return List<Map<String, dynamic>>.from(response);
  }


  Future<String?> placeOrder(
      List<CartItemModel> cartItems, String chefId, Map<String, FoodModel> foodMap) async {
    final customerId = supabase.auth.currentUser!.id;

    final totalAmount = cartItems.fold<double>(
      0.0,
          (sum, item) {
        final food = foodMap[item.foodId];
        return food != null ? sum + (food.price * item.quantity) : sum;
      },
    );

    // Insert order
    final orderRes = await supabase
        .from('orders')
        .insert({
      'customer_id': customerId,
      'chef_id': chefId,
      'status': 'pending',
      'total_amount': totalAmount,
      'created_at': DateTime.now().toIso8601String()
    })
        .select()
        .single();

    final orderId = orderRes['id'];

    // Insert order items
    for (var item in cartItems) {
      final food = foodMap[item.foodId];
      if (food != null) {
        await supabase.from('order_items').insert({
          'order_id': orderId,
          'food_id': item.foodId,
          'quantity': item.quantity,
          'price': food.price,
        });
      }
    }

    // Clear the cart
    await supabase.from('carts').delete().eq('customer_id', customerId);

    return orderId;
  }
}
