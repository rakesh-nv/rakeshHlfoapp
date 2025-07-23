import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/food_model.dart';

class FoodService {
  final supabase = Supabase.instance.client;

  // 🔍 Get foods for current chef
  Future<List<FoodModel>> getFoodsByChef() async {
    final userId = supabase.auth.currentUser!.id;

    final response = await supabase
        .from('foods')
        .select('*')
        .eq('chef_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((item) => FoodModel.fromMap(item)).toList();
  }

  // 🔍 Get restaurant ID for the current chef
  Future<String?> getRestaurantIdByChef() async {
    final chefId = supabase.auth.currentUser!.id;

    final response = await supabase
        .from('restaurants')
        .select('id')
        .eq('chef_id', chefId)
        .maybeSingle();

    return response?['id'];
  }

  // ➕ Add new food item
  Future<void> addFood(FoodModel food) async {
    final chefId = supabase.auth.currentUser!.id;
    final restaurantId = await getRestaurantIdByChef();

    if (restaurantId == null) {
      throw Exception("No restaurant found for current chef");
    }

    final response = await supabase.from('foods').insert({
      'chef_id': chefId,
      'restaurant_id': restaurantId,
      'title': food.title,
      'description': food.description,
      'price': food.price,
      'image_url': food.imageUrl,
      'is_available': food.isAvailable,
      'category': food.category,
    });

    if (response != null && response is PostgrestException) {
      throw Exception("Add food failed: ${response.message}");
    }
  }

  // ✏️ Update food
  Future<void> updateFood(FoodModel food) async {
    final response = await supabase.from('foods').update({
      'title': food.title,
      'description': food.description,
      'price': food.price,
      'image_url': food.imageUrl,
      'is_available': food.isAvailable,
      'category': food.category,
    }).eq('id', food.id);

    if (response != null && response is PostgrestException) {
      throw Exception("Update food failed: ${response.message}");
    }
  }

  // ❌ Delete food
  Future<void> deleteFood(String foodId) async {
    final response = await supabase.from('foods').delete().eq('id', foodId);

    if (response != null && response is PostgrestException) {
      throw Exception("Delete food failed: ${response.message}");
    }
  }
}
