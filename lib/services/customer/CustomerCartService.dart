import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/customer_models/cart_model.dart';
import '../../models/chef_models/food_model.dart';

class CustomerCartService {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName = 'carts';

  Future<List<CartItemModel>> fetchCartItems(String customerId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    print("cart");
    print(response);
    return (response as List).map((e) => CartItemModel.fromMap(e)).toList();
  }

  Future<void> addToCart(CartItemModel item) async {
    await client.from(tableName).insert(item.toMap());
  }

  Future<void> updateQuantity(String cartId, int newQty) async {
    await client.from(tableName).update({'quantity': newQty}).eq('id', cartId);
  }

  Future<void> removeFromCart(String cartId) async {
    await client.from(tableName).delete().eq('id', cartId);
  }

  Future<CartItemModel?> getCartItem(String customerId, String foodId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('customer_id', customerId)
        .eq('food_id', foodId)
        .maybeSingle();

    if (response != null) {
      return CartItemModel.fromMap(response);
    }
    return null;
  }

// // Inside customer_food_service.dart
// Future<FoodModel?> getFoodById(String foodId) async {
//   final response = await client
//       .from('foods')
//       .select()
//       .eq('id', foodId)
//       .maybeSingle();
//
//   if (response != null) {
//     return FoodModel.fromMap(response);
//   }
//   return null;
// }

}