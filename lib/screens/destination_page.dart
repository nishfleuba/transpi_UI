import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_service.dart';
import 'destination_map_page.dart';

class DestinationPage extends StatefulWidget {
  const DestinationPage({super.key});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  final destinationController = TextEditingController();

  Position? currentPosition;

  bool isLoadingLocation = true;

  // Indique si nous sommes en train de chercher
  // les coordonnées et les adresses
  bool isGeocoding = false;

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
  }

  // =====================================================
  // RÉCUPÉRER LA POSITION ACTUELLE DU PASSAGER
  // =====================================================

  Future<void> getCurrentLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print(
        'Le service de localisation est désactivé.',
      );

      if (!mounted) return;

      setState(() {
        isLoadingLocation = false;
      });

      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print(
          'Permission de localisation refusée.',
        );

        if (!mounted) return;

        setState(() {
          isLoadingLocation = false;
        });

        return;
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {
      print(
        'Permission de localisation refusée définitivement.',
      );

      if (!mounted) return;

      setState(() {
        isLoadingLocation = false;
      });

      return;
    }

    try {
      final position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        isLoadingLocation = false;
      });

      print('Position actuelle :');
      print(
        'Latitude : ${position.latitude}',
      );
      print(
        'Longitude : ${position.longitude}',
      );
    } catch (e) {
      print(
        'Erreur récupération position : $e',
      );

      if (!mounted) return;

      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  // =====================================================
  // GÉOCODER LA DESTINATION + ADRESSE DU DÉPART
  // =====================================================

  Future<void> searchDestination() async {
    final destination =
        destinationController.text.trim();

    // Vérifier que le champ destination n'est pas vide
    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez entrer une destination.',
          ),
        ),
      );

      return;
    }

    // Vérifier que la position de départ existe
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Votre position actuelle est indisponible.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isGeocoding = true;
    });

    try {
      // =================================================
      // 1. RÉCUPÉRER L'ADRESSE DU DÉPART
      // =================================================

      print(
        '===== GÉOCODAGE INVERSE DÉPART =====',
      );

      print(
        'Latitude départ : '
        '${currentPosition!.latitude}',
      );

      print(
        'Longitude départ : '
        '${currentPosition!.longitude}',
      );

      final pickupResult =
          await ApiService.reverseGeocode(
        latitude:
            currentPosition!.latitude,
        longitude:
            currentPosition!.longitude,
      );

      final pickupAddress =
          pickupResult['address'].toString();

      print(
        'Adresse départ : $pickupAddress',
      );

      // =================================================
      // 2. GÉOCODER LA DESTINATION
      // =================================================

      print(
        '===== GÉOCODAGE DESTINATION =====',
      );

      print(
        'Adresse recherchée : $destination',
      );

      final result =
          await ApiService.geocodeAddress(
        destination,
      );

      final latitude =
          double.parse(
        result['latitude'].toString(),
      );

      final longitude =
          double.parse(
        result['longitude'].toString(),
      );

      final address =
          result['address'].toString();

      print(
        'Adresse destination : $address',
      );

      print(
        'Latitude destination : $latitude',
      );

      print(
        'Longitude destination : $longitude',
      );

      // =================================================
      // 3. ALLER VERS LA CARTE
      // =================================================

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DestinationMapPage(
            // -----------------------------
            // DÉPART
            // -----------------------------

            departureLatitude:
                currentPosition!.latitude,

            departureLongitude:
                currentPosition!.longitude,

            departureAddress:
                pickupAddress,

            // -----------------------------
            // DESTINATION
            // -----------------------------

            destinationAddress:
                address,

            destinationLatitude:
                latitude,

            destinationLongitude:
                longitude,
          ),
        ),
      );
    } catch (e) {
      print(
        'Erreur de géocodage : $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de préparer le trajet : $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGeocoding = false;
        });
      }
    }
  }

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  // =====================================================
  // INTERFACE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Où allez-vous ?',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =================================================
            // DÉPART
            // =================================================

            const Text(
              'Départ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: isLoadingLocation
                        ? const Text(
                            'Recherche de votre position...',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          )
                        : currentPosition != null
                            ? const Text(
                                'Ma position actuelle',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              )
                            : const Text(
                                'Position indisponible',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // DESTINATION
            // =================================================

            const Text(
              'Destination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  destinationController,

              decoration:
                  const InputDecoration(
                hintText:
                    'Où allez-vous ?',

                prefixIcon:
                    Icon(Icons.search),

                border:
                    OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            // =================================================
            // BOUTON CONTINUER
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                    isGeocoding
                        ? null
                        : searchDestination,

                child: isGeocoding
                    ? const SizedBox(
                        width: 24,
                        height: 24,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Continuer',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}