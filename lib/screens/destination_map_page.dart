import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'categories_page.dart';

class DestinationMapPage extends StatefulWidget {
  final double departureLatitude;
  final double departureLongitude;
  final String departureAddress;

  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;

  const DestinationMapPage({
    super.key,
    required this.departureLatitude,
    required this.departureLongitude,
    required this.departureAddress,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
  });

  @override
  State<DestinationMapPage> createState() =>
      _DestinationMapPageState();
}

class _DestinationMapPageState
    extends State<DestinationMapPage> {

  final MapController mapController =
      MapController();

  LatLng? selectedLocation;

  // Variables pour les infos de trajet
  double? distanceKm;
  int? estimatedMinutes;

  @override
  void initState() {
    super.initState();

    // Destination trouvée automatiquement
    selectedLocation = LatLng(
      widget.destinationLatitude,
      widget.destinationLongitude,
    );

    // Calculer la distance et le temps
    distanceKm = calculateDistance(
      widget.departureLatitude,
      widget.departureLongitude,
      widget.destinationLatitude,
      widget.destinationLongitude,
    );

    // Estimer le temps (30 km/h en ville)
    estimatedMinutes = ((distanceKm! / 30) * 60).round();

    print('===== DESTINATION REÇUE =====');

    print(
      'Adresse départ : '
      '${widget.departureAddress}',
    );

    print(
      'Latitude départ : '
      '${widget.departureLatitude}',
    );

    print(
      'Longitude départ : '
      '${widget.departureLongitude}',
    );

    print(
      'Adresse destination : '
      '${widget.destinationAddress}',
    );

    print(
      'Latitude destination : '
      '${widget.destinationLatitude}',
    );

    print(
      'Longitude destination : '
      '${widget.destinationLongitude}',
    );

    print('Distance: $distanceKm km');
    print('Temps estimé: $estimatedMinutes min');
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  // =====================================================
  // AFFICHER DÉPART + DESTINATION
  // =====================================================

  void showEntireRoute() {
    final departure = LatLng(
      widget.departureLatitude,
      widget.departureLongitude,
    );

    final destination = LatLng(
      widget.destinationLatitude,
      widget.destinationLongitude,
    );

    final bounds = LatLngBounds(
      departure,
      destination,
    );

    mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(
          60,
          150,
          60,
          150,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Confirmer la destination',
        ),
      ),

      body: Stack(
        children: [

          // =====================================================
          // CARTE
          // =====================================================

          FlutterMap(
            mapController: mapController,

            options: MapOptions(
              initialCenter: LatLng(
                (
                  widget.departureLatitude +
                  widget.destinationLatitude
                ) /
                    2,

                (
                  widget.departureLongitude +
                  widget.destinationLongitude
                ) /
                    2,
              ),

              initialZoom: 13,

              onMapReady: () {
                showEntireRoute();
              },

              // Le passager peut modifier
              // manuellement la destination.
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });

                print(
                  'Nouvelle destination - Latitude : '
                  '${point.latitude}',
                );

                print(
                  'Nouvelle destination - Longitude : '
                  '${point.longitude}',
                );
              },
            ),

            children: [

              // =====================================================
              // FOND DE CARTE
              // =====================================================

              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName:
                    'com.example.transpi',
              ),

              // =====================================================
              // MARQUEURS
              // =====================================================

              MarkerLayer(
                markers: [

                  // =================================================
                  // DÉPART
                  // =================================================

                  Marker(
                    point: LatLng(
                      widget.departureLatitude,
                      widget.departureLongitude,
                    ),

                    width: 55,
                    height: 55,

                    child: const Icon(
                      Icons.my_location,
                      color: Colors.green,
                      size: 45,
                    ),
                  ),

                  // =================================================
                  // DESTINATION
                  // =================================================

                  if (selectedLocation != null)
                    Marker(
                      point: selectedLocation!,

                      width: 55,
                      height: 55,

                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // =====================================================
          // INFORMATIONS DESTINATION
          // =====================================================

          Positioned(
            left: 16,
            right: 16,
            top: 16,

            child: Container(
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(15),

                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black26,
                  ),
                ],
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      widget.destinationAddress,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // INFO-BOX TRAJET
          // =====================================================

          Positioned(
            left: 16,
            right: 16,
            bottom: 95,

            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black26,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    Icons.route,
                    '${distanceKm?.toStringAsFixed(1)} km',
                    'Distance',
                  ),
                  _buildInfoItem(
                    Icons.access_time,
                    '$estimatedMinutes min',
                    'Temps',
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // BOUTON RECENTRER
          // =====================================================

          Positioned(
            right: 16,
            bottom: 175,

            child: FloatingActionButton(
              heroTag: 'center_route',

              onPressed: showEntireRoute,

              child: const Icon(
                Icons.center_focus_strong,
              ),
            ),
          ),

          // =====================================================
          // BOUTON CONTINUER
          // =====================================================

          Positioned(
            left: 16,
            right: 16,
            bottom: 20,

            child: SizedBox(
              height: 55,

              child: ElevatedButton(
                onPressed:
                    selectedLocation == null
                        ? null
                        : () {

                            print(
                              '===== TRAJET =====',
                            );

                            print(
                              'Adresse départ : '
                              '${widget.departureAddress}',
                            );

                            print(
                              'Départ latitude : '
                              '${widget.departureLatitude}',
                            );

                            print(
                              'Départ longitude : '
                              '${widget.departureLongitude}',
                            );

                            print(
                              'Adresse destination : '
                              '${widget.destinationAddress}',
                            );

                            print(
                              'Destination latitude : '
                              '${selectedLocation!.latitude}',
                            );

                            print(
                              'Destination longitude : '
                              '${selectedLocation!.longitude}',
                            );

                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (context) =>
                                    CategoriesPage(

                                  // -------------------------
                                  // DÉPART
                                  // -------------------------

                                  departureLatitude:
                                      widget
                                          .departureLatitude,

                                  departureLongitude:
                                      widget
                                          .departureLongitude,

                                  departureAddress:
                                      widget
                                          .departureAddress,

                                  // -------------------------
                                  // DESTINATION
                                  // -------------------------

                                  destinationLatitude:
                                      selectedLocation!
                                          .latitude,

                                  destinationLongitude:
                                      selectedLocation!
                                          .longitude,

                                  destinationAddress:
                                      widget
                                          .destinationAddress,
                                ),
                              ),
                            );
                          },

                child: const Text(
                  'Confirmer la destination',

                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}