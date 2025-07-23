class CustomerRestaurantModel {
  final String id;
  final String chefId;
  final String name;
  final String address;
  final String description;
  final String imageUrl;

  CustomerRestaurantModel({
    required this.id,
    required this.chefId,
    required this.name,
    required this.address,
    required this.description,
    required this.imageUrl,
  });

  factory CustomerRestaurantModel.fromJson(Map<String, dynamic> json) {
    return CustomerRestaurantModel(
      id: json['id'],
      chefId: json['chef_id'],
      name: json['name'],
      address: json['address'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
