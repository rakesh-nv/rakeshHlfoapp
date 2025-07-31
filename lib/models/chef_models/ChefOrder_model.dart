// models/chef_models/chef_order_model.dart

class ChefOrderModel {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final List<ChefOrderItemModel> items;

  ChefOrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });
}

class ChefOrderItemModel {
  final String foodTitle;
  final int quantity;
  final double price;

  ChefOrderItemModel({
    required this.foodTitle,
    required this.quantity,
    required this.price,
  });
}
