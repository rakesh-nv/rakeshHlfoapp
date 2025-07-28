import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/customer_models/customer_item_midel.dart';
import '../../models/food_model.dart';

class CustomerFoodService {
  final supabase = Supabase.instance.client;

  Future<List<CustomerFoodModel>> fetchFoodsByRestaurant(String restaurantId) async {
    final response = await supabase
        .from('foods')
        .select('*')
        .eq('restaurant_id', restaurantId)
        .eq('is_available', true);

    final data = response as List;

    return data.map((item) => CustomerFoodModel.fromMap(item)).toList();
  }

  // Inside customer_food_service.dart
  Future<FoodModel?> getFoodById(String foodId) async {
    final response = await supabase
        .from('foods')
        .select('*')
        .eq('id', foodId)
        .maybeSingle();

    if (response != null) {
      return FoodModel.fromMap(response);
    }
    return null;
  }

}
