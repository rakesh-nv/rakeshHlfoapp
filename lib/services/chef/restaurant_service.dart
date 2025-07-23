// services/restaurant_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/restaurant_model.dart';

class RestaurantService {
  final supabase = Supabase.instance.client;

  // Future<void> addRestaurant({
  //   required String name,
  //   required String address,
  //   required String description,
  //   required String imageUrl,
  // }) async {
  //   final user = supabase.auth.currentUser;
  //   if (user == null) throw Exception("User not logged in");
  //
  //   await supabase.from('restaurants').insert({
  //     'chef_id': user.id,
  //     'name': name,
  //     'address': address,
  //     'description': description,
  //     'image_url': imageUrl,
  //   });
  // }

  Future<void> upsertRestaurant({
    required String name,
    required String address,
    required String description,
    required String imageUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final existing = await getMyRestaurant(); // check if restaurant exists

    final restaurantData = {
      'chef_id': user.id,
      'name': name,
      'address': address,
      'description': description,
      'image_url': imageUrl,
    };

    if (existing != null) {
      // If restaurant exists, include its ID for update
      restaurantData['id'] = existing.id;
    }

    await supabase.from('restaurants').upsert(restaurantData);
  }



  Future<Restaurant?> getMyRestaurant() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final res = await supabase
        .from('restaurants')
        .select()
        .eq('chef_id', user.id)
        .maybeSingle();

    if (res == null) return null;
    return Restaurant.fromMap(res);
  }
}
