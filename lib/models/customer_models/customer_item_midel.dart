class CustomerFoodModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final String restaurantId; // ✅ Change from int to String

  CustomerFoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.isAvailable,
    required this.restaurantId,
  });

  factory CustomerFoodModel.fromMap(Map<String, dynamic> map) {
    try {
      return CustomerFoodModel(
        id: map['id'] ?? '',
        name: map['title'] ?? '',
        description: map['description'] ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        category: map['category'] ?? '',
        imageUrl: map['image_url'] ?? '',
        isAvailable: map['is_available'] ?? false,
        restaurantId: map['restaurant_id'] ?? '',
      );
    } catch (e) {
      print("❌ Error parsing food item: $e\nMap: $map");
      return CustomerFoodModel(
        id: '',
        name: 'Unknown',
        description: '',
        price: 0,
        category: '',
        imageUrl: '',
        isAvailable: false,
        restaurantId: '',
      );
    }
  }
}
