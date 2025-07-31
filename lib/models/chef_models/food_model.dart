class FoodModel {
  final String id;
  final String chefId;
  final String restaurantId;
  final String title;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final String? category; // 🆕 category

  FoodModel({
    required this.id,
    required this.chefId,
    required this.restaurantId,
    required this.title,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
    this.category,
  });

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'],
      chefId: map['chef_id'],
      restaurantId: map['restaurant_id'],
      title: map['title'],
      description: map['description'],
      price: double.parse(map['price'].toString()),
      imageUrl: map['image_url'],
      isAvailable: map['is_available'],
      createdAt: DateTime.parse(map['created_at']),
      category: map['category'], // 🆕
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chef_id': chefId,
      'restaurant_id': restaurantId,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'category': category, // 🆕
    };
  }
}

