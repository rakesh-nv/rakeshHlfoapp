class CustomerOrderModel {
  final String id;
  final String chefId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  CustomerOrderModel({
    required this.id,
    required this.chefId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderModel(
      id: json['id'],
      chefId: json['chef_id'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
