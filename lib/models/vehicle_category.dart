class VehicleCategory {
  final int id;
  final String name;
  final String description;
  final double basePrice;
  final double pricePerKm;
  final double pricePerMinute;
  final double serviceFee;
  final int maxPassengers;
  final bool isActive;
  final DateTime createdAt;

  VehicleCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.pricePerKm,
    required this.pricePerMinute,
    required this.serviceFee,
    required this.maxPassengers,
    required this.isActive,
    required this.createdAt,
  });

  factory VehicleCategory.fromJson(Map<String, dynamic> json) {
    return VehicleCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      basePrice: double.parse(json['base_price'].toString()),
      pricePerKm: double.parse(json['price_per_km'].toString()),
      pricePerMinute: double.parse(json['price_per_minute'].toString()),
      serviceFee: double.parse(json['service_fee'].toString()),
      maxPassengers: json['max_passengers'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}