import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerCategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<String>> fetchCategories() async {
    final response = await _supabase
        .from('foods')
        .select('category')
        .not('category', 'is', null)
        .order('category', ascending: true);

    final categories = <String>[];
    if (response != null && response is List) {
      final uniqueCategories = response
          .map((item) => item['category'] as String)
          .where((category) => category != null)
          .toSet()
          .toList();
      categories.addAll(uniqueCategories);
    }
    return categories;
  }
}
