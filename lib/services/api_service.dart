import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/trip.dart';
import '../models/vehicle_category.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/';

  static Future<http.Response> get(String endpoint) async {
    final token = await AuthService.getAccessToken();

    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }

    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await AuthService.getAccessToken();

    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
  static Future<List<dynamic>> getAvailableTrips() async {
    final response = await get(
      '/api/transport/trips/available-trips/',
    );

    print('===== COURSES DISPONIBLES =====');
    print('STATUS : ${response.statusCode}');
    print('BODY : ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Impossible de récupérer les courses disponibles. '
      'Code: ${response.statusCode} '
      'Body: ${response.body}',
    );
  }

  static Future<Trip> acceptTrip(int tripId) async {
    final response = await post(
      '/api/transport/trips/$tripId/accept/',
      {},
    );

    print('===== ACCEPTATION COURSE =====');
    print('STATUS : ${response.statusCode}');
    print('BODY : ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return Trip.fromJson(json);
    }

    throw Exception(
      'Impossible d\'accepter la course. '
      'Code: ${response.statusCode} '
      'Body: ${response.body}',
    );
  }

  static Future<Trip> arrivedTrip(int tripId) async {
  final response = await post(
    '/api/transport/trips/$tripId/arrived/',
    {},
  );

  print('===== CHAUFFEUR ARRIVÉ =====');
  print('STATUS : ${response.statusCode}');
  print('BODY : ${response.body}');

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Trip.fromJson(json);
  }

  throw Exception(
    'Impossible de signaler l\'arrivée. '
    'Code: ${response.statusCode} Body: ${response.body}',
  );
}

static Future<Trip> startTrip(int tripId) async {
  final response = await post(
    '/api/transport/trips/$tripId/start/',
    {},
  );

  print('===== DÉMARRAGE COURSE =====');
  print('STATUS : ${response.statusCode}');
  print('BODY : ${response.body}');

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Trip.fromJson(json);
  }

  throw Exception(
    'Impossible de démarrer la course. '
    'Code: ${response.statusCode} Body: ${response.body}',
  );
}

static Future<Trip> completeTrip(int tripId) async {
  final response = await post(
    '/api/transport/trips/$tripId/complete/',
    {},
  );

  print('===== FIN COURSE =====');
  print('STATUS : ${response.statusCode}');
  print('BODY : ${response.body}');

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Trip.fromJson(json);
  }

  throw Exception(
    'Impossible de terminer la course. '
    'Code: ${response.statusCode} Body: ${response.body}',
  );
}

  static Future<Map<String, dynamic>> geocodeAddress(
    String address,
  ) async {
    final token = await AuthService.getAccessToken();

    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/transport/geocode/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Erreur géocodage : ${response.statusCode} ${response.body}',
    );
  }
  static Future<Map<String, dynamic>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final token = await AuthService.getAccessToken();

    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/transport/geocode/reverse/',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    print('===== GÉOCODAGE INVERSE =====');
    print('STATUS : ${response.statusCode}');
    print('BODY : ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Erreur géocodage inverse : '
      '${response.statusCode} ${response.body}',
    );
  }

  static Future<Trip> getTrip(int tripId) async {
    final response = await get(
      '/api/transport/trips/$tripId/',
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return Trip.fromJson(json);
    }

    throw Exception(
      'Impossible de récupérer la course. '
      'Code: ${response.statusCode}',
    );
  }

  static Future<List<VehicleCategory>> getVehicleCategories() async {
    final response = await get(
      '/api/transport/categories/',
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);

      return json
          .map((item) => VehicleCategory.fromJson(item))
          .toList();
    }

    throw Exception(
      'Impossible de récupérer les catégories. '
      'Code: ${response.statusCode}',
    );
  }

  static Future<Trip> createTrip({
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationAddress,
    required int vehicleCategoryId,
  }) async {
    final token = await AuthService.getAccessToken();

    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/transport/trips/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'pickup_address': pickupAddress,

        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'destination_address': destinationAddress,

        'vehicle_category': vehicleCategoryId,
      }),
    );

    print('===== CRÉATION COURSE =====');
    print('STATUS : ${response.statusCode}');
    print('BODY : ${response.body}');

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Trip.fromJson(json);
    }

    throw Exception(
      'Impossible de créer la course. '
      'Code: ${response.statusCode} '
      'Body: ${response.body}',
    );
  }
}