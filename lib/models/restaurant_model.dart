// models/restaurant_model.dart

class Restaurant {
  final String id;
  final String chefId;
  final String name;
  final String address;
  final String description;
  final String imageUrl;
  final DateTime createdAt;

  Restaurant({
    required this.id,
    required this.chefId,
    required this.name,
    required this.address,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      chefId: map['chef_id'],
      name: map['name'],
      address: map['address'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chef_id': chefId,
      'name': name,
      'address': address,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
