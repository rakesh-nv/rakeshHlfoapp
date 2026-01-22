import 'package:supabase_flutter/supabase_flutter.dart';

class EarningService {
  final supabase = Supabase.instance.client;

  Future<double> getDailyEarnings(String chefId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final response = await supabase
        .from('orders')
        .select('total_amount')
        .eq('chef_id', chefId)
        .gte('created_at', startOfDay.toIso8601String())
        .lte('created_at', endOfDay.toIso8601String())
        .eq('status', 'delivered'); // Only count delivered orders as earnings

    double totalEarnings = 0.0;
    if (response != null) {
      for (var order in response) {
        totalEarnings += (order['total_amount'] as num).toDouble();
      }
    }
    return totalEarnings;
  }

  Future<double> getMonthlyEarnings(String chefId, DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 1)
        .subtract(const Duration(milliseconds: 1));

    final response = await supabase
        .from('orders')
        .select('total_amount')
        .eq('chef_id', chefId)
        .gte('created_at', startOfMonth.toIso8601String())
        .lte('created_at', endOfMonth.toIso8601String())
        .eq('status', 'delivered'); // Only count delivered orders as earnings

    double totalEarnings = 0.0;
    if (response != null) {
      for (var order in response) {
        totalEarnings += (order['total_amount'] as num).toDouble();
      }
    }
    return totalEarnings;
  }
}
