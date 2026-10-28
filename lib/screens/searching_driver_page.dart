import 'dart:async';

import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../services/api_service.dart';

class SearchingDriverPage extends StatefulWidget {
  final Trip trip;

  const SearchingDriverPage({
    super.key,
    required this.trip,
  });

  @override
  State<SearchingDriverPage> createState() =>
      _SearchingDriverPageState();
}

class _SearchingDriverPageState
    extends State<SearchingDriverPage> {

  Timer? timer;

  Trip? currentTrip;

  bool isLoading = true;

  // Évite d'afficher plusieurs fois le message
  // lorsque le chauffeur est arrivé.
  bool arrivalMessageShown = false;

  @override
  void initState() {
    super.initState();

    currentTrip = widget.trip;

    startCheckingTrip();
  }

  // =====================================================
  // SURVEILLER LA COURSE
  // =====================================================

  void startCheckingTrip() {
    checkTripStatus();

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        checkTripStatus();
      },
    );
  }

  // =====================================================
  // RÉCUPÉRER LA COURSE
  // =====================================================

  Future<void> checkTripStatus() async {
    try {
      final trip = await ApiService.getTrip(
        widget.trip.id,
      );

      if (!mounted) return;

      setState(() {
        currentTrip = trip;
        isLoading = false;
      });

      print('===== VÉRIFICATION COURSE =====');
      print('Trip ID : ${trip.id}');
      print('Statut : ${trip.status}');
      print('Driver : ${trip.driver?.username}');

      // =================================================
      // CHAUFFEUR TROUVÉ
      // =================================================

      if (trip.status == 'DRIVER_ASSIGNED') {
        print('===== CHAUFFEUR TROUVÉ =====');

      }

      // =================================================
      // CHAUFFEUR ARRIVÉ
      // =================================================

      if (trip.status == 'DRIVER_ARRIVED') {
        print('===== CHAUFFEUR ARRIVÉ =====');

        timer?.cancel();

        if (!arrivalMessageShown) {
          arrivalMessageShown = true;

          _showMessage(
            'Votre chauffeur est arrivé !',
          );
        }
      }
    } catch (e) {
      print(
        'Erreur vérification course : $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =====================================================
  // MESSAGE
  // =====================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  // =====================================================
  // INTERFACE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final trip = currentTrip;

    final driver = trip?.driver;

    final vehicle = driver?.vehicle;

    final driverAssigned =
        trip?.status == 'DRIVER_ASSIGNED';

    final driverArrived =
        trip?.status == 'DRIVER_ARRIVED';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recherche de chauffeur',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 30),

            // =================================================
            // ICÔNE
            // =================================================

            Center(
              child: Icon(
                driverArrived
                    ? Icons.check_circle
                    : Icons.directions_car,
                size: 80,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // TITRE
            // =================================================

            Center(
              child: Text(
                driverArrived
                    ? 'Votre chauffeur est arrivé !'
                    : driverAssigned
                        ? 'Chauffeur trouvé !'
                        : 'Recherche d’un chauffeur',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // =================================================
            // MESSAGE
            // =================================================

            Center(
              child: Text(
                driverArrived
                    ? 'Votre chauffeur vous attend au point de départ.'
                    : driverAssigned
                        ? 'Un chauffeur a été attribué à votre course.'
                        : 'Nous recherchons un chauffeur disponible...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // INDICATEUR DE RECHERCHE
            // =================================================

            if (!driverAssigned && !driverArrived)
              const Center(
                child: CircularProgressIndicator(),
              ),

            // =================================================
            // INFORMATIONS DU CHAUFFEUR
            // =================================================

            if ((driverAssigned || driverArrived) &&
                driver != null) ...[
              
              const SizedBox(height: 10),

              Card(
                elevation: 3,

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      // -------------------------------------------------
                      // ICÔNE CHAUFFEUR
                      // -------------------------------------------------

                      const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.green,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Votre chauffeur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // -------------------------------------------------
                      // NOM
                      // -------------------------------------------------

                      Text(
                        driver.username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // -------------------------------------------------
                      // NOTE
                      // -------------------------------------------------

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            driver.rating.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Divider(),

                      const SizedBox(height: 15),

                      // =================================================
                      // INFORMATIONS DU VÉHICULE
                      // =================================================

                      if (vehicle != null) ...[

                        const Icon(
                          Icons.directions_car,
                          size: 45,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '${vehicle.brand} ${vehicle.model}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          vehicle.color,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          vehicle.category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${vehicle.numberOfSeats} places',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // MESSAGE LORSQUE LE CHAUFFEUR EST ARRIVÉ
              // =================================================

              if (driverArrived)
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12),

                    border: Border.all(
                      color: Colors.green,
                    ),
                  ),

                  child: Column(
                    children: [

                      const Icon(
                        Icons.location_on,
                        size: 35,
                        color: Colors.green,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Votre chauffeur est arrivé',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Votre chauffeur vous attend au point de départ.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            // =================================================
            // INFORMATIONS DE LA COURSE
            // =================================================

            const Text(
              'Votre course',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            if (trip != null) ...[

              // -------------------------------------------------
              // NUMÉRO DE COURSE
              // -------------------------------------------------

              ListTile(
                contentPadding: EdgeInsets.zero,

                leading: const Icon(
                  Icons.confirmation_number,
                ),

                title: const Text(
                  'Course',
                ),

                subtitle: Text(
                  '#${trip.id}',
                ),
              ),

              // -------------------------------------------------
              // DÉPART
              // -------------------------------------------------

              ListTile(
                contentPadding: EdgeInsets.zero,

                leading: const Icon(
                  Icons.location_on,
                ),

                title: const Text(
                  'Départ',
                ),

                subtitle: Text(
                  trip.pickupAddress,
                ),
              ),

              // -------------------------------------------------
              // DESTINATION
              // -------------------------------------------------

              ListTile(
                contentPadding: EdgeInsets.zero,

                leading: const Icon(
                  Icons.flag,
                ),

                title: const Text(
                  'Destination',
                ),

                subtitle: Text(
                  trip.destinationAddress,
                ),
              ),

              // -------------------------------------------------
              // DISTANCE
              // -------------------------------------------------

              ListTile(
                contentPadding: EdgeInsets.zero,

                leading: const Icon(
                  Icons.route,
                ),

                title: const Text(
                  'Distance',
                ),

                subtitle: Text(
                  '${trip.distanceKm} km',
                ),
              ),

              // -------------------------------------------------
              // DURÉE
              // -------------------------------------------------

              ListTile(
                contentPadding: EdgeInsets.zero,

                leading: const Icon(
                  Icons.access_time,
                ),

                title: const Text(
                  'Durée estimée',
                ),

                subtitle: Text(
                  '${trip.estimatedDuration} minutes',
                ),
              ),

              // -------------------------------------------------
              // PRIX
              // -------------------------------------------------

              ListTile(
                contentPadding: EdgeInsets.zero,

                leading: const Icon(
                  Icons.payments,
                ),

                title: const Text(
                  'Prix estimé',
                ),

                subtitle: Text(
                  trip.estimatedPrice != null
                      ? '${trip.estimatedPrice}'
                      : 'Non disponible',
                ),
              ),
            ],

            const SizedBox(height: 10),

            // =================================================
            // STATUT
            // =================================================

            Center(
              child: Text(
                trip?.status ?? 'Chargement...',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}