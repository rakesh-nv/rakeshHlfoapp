import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/customer_models/customer_restaurant_model.dart';

class CustomerRestaurantService {
  final _client = Supabase.instance.client;

  Future<List<CustomerRestaurantModel>> fetchRestaurants() async {
    final response = await _client
        .from('restaurants')
        .select();

    final data = response as List<dynamic>;

    return data.map((item) => CustomerRestaurantModel.fromJson(item)).toList();
  }
}
