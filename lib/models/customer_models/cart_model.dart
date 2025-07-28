class CartItemModel {
  final String id;
  final String customerId;
  final String foodId;
  // final String description;
  final int quantity;

  CartItemModel( {
    required this.id,
    required this.customerId,
    // required this.description,
    required this.foodId,
    required this.quantity,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'],
      customerId: map['customer_id'],
      foodId: map['food_id'],
      quantity: map['quantity'],
      // description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'food_id': foodId,
      'quantity': quantity,
      // 'description':description
    };
  }
}
