class Trip {
  final int id;
  final String status;

  final int passenger;
  final DriverInfo? driver;
  final int vehicleCategory;

  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;

  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;

  final double distanceKm;
  final int estimatedDuration;

  final double? estimatedPrice;
  final double? finalPrice;

  final bool isScheduled;
  final DateTime? scheduledAt;

  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  Trip({
    required this.id,
    required this.status,
    required this.passenger,
    this.driver,
    required this.vehicleCategory,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.distanceKm,
    required this.estimatedDuration,
    this.estimatedPrice,
    this.finalPrice,
    required this.isScheduled,
    this.scheduledAt,
    required this.requestedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      status: json['status'],

      passenger: json['passenger'],

      driver: json['driver'] != null
          ? DriverInfo.fromJson(json['driver'])
          : null,

      vehicleCategory: json['vehicle_category'],

      pickupAddress: json['pickup_address'],
      pickupLatitude:
          double.parse(json['pickup_latitude'].toString()),
      pickupLongitude:
          double.parse(json['pickup_longitude'].toString()),

      destinationAddress: json['destination_address'],
      destinationLatitude:
          double.parse(json['destination_latitude'].toString()),
      destinationLongitude:
          double.parse(json['destination_longitude'].toString()),

      distanceKm:
          double.parse(json['distance_km'].toString()),
      estimatedDuration:
          json['estimated_duration'],

      estimatedPrice: json['estimated_price'] != null
          ? double.parse(
              json['estimated_price'].toString(),
            )
          : null,

      finalPrice: json['final_price'] != null
          ? double.parse(
              json['final_price'].toString(),
            )
          : null,

      isScheduled: json['is_scheduled'],

      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : null,

      requestedAt:
          DateTime.parse(json['requested_at']),

      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,

      arrivedAt: json['arrived_at'] != null
          ? DateTime.parse(json['arrived_at'])
          : null,

      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,

      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,

      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
    );
  }
}


// =====================================================
// INFORMATIONS DU CHAUFFEUR
// =====================================================

class DriverInfo {
  final int id;
  final String username;
  final double rating;
  final int totalRides;
  final VehicleInfo? vehicle;

  DriverInfo({
    required this.id,
    required this.username,
    required this.rating,
    required this.totalRides,
    this.vehicle,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'],
      username: json['username'] ?? '',
      rating: double.parse(
        json['rating']?.toString() ?? '0',
      ),
      totalRides: json['total_rides'] ?? 0,

      vehicle: json['vehicle'] != null
          ? VehicleInfo.fromJson(json['vehicle'])
          : null,
    );
  }
}


// =====================================================
// INFORMATIONS DU VÉHICULE
// =====================================================

class VehicleInfo {
  final String category;
  final String vehicleType;
  final String brand;
  final String model;
  final String color;
  final int numberOfSeats;

  VehicleInfo({
    required this.category,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.color,
    required this.numberOfSeats,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      category: json['category'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      numberOfSeats: json['number_of_seats'] ?? 0,
    );
  }
}