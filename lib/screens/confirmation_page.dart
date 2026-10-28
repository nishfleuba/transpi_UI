import 'package:flutter/material.dart';
import '../models/vehicle_category.dart';
import '../models/trip.dart';
import '../services/api_service.dart';
import 'searching_driver_page.dart';

class ConfirmationPage extends StatefulWidget {
  final double departureLatitude;
  final double departureLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationAddress;
  final VehicleCategory selectedCategory;
  final String departureAddress;

  const ConfirmationPage({
    super.key,
    required this.departureLatitude,
    required this.departureLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationAddress,
    required this.selectedCategory,
    required this.departureAddress,
  });

  @override
  State<ConfirmationPage> createState() =>
      _ConfirmationPageState();
}

class _ConfirmationPageState
    extends State<ConfirmationPage> {

  bool isLoading = false;

  // Course créée par le backend
  Trip? createdTrip;

  // =====================================================
  // CRÉER LA COURSE
  // =====================================================

  Future<void> createTrip() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      print('===== COMMANDE COURSE =====');

      print(
        'Départ latitude : '
        '${widget.departureLatitude}',
      );

      print(
        'Départ longitude : '
        '${widget.departureLongitude}',
      );

      print(
        'Destination latitude : '
        '${widget.destinationLatitude}',
      );

      print(
        'Destination longitude : '
        '${widget.destinationLongitude}',
      );

      print(
        'Catégorie : '
        '${widget.selectedCategory.name}',
      );

      print(
        'Catégorie ID : '
        '${widget.selectedCategory.id}',
      );

      final trip = await ApiService.createTrip(
        pickupLatitude: widget.departureLatitude,
        pickupLongitude: widget.departureLongitude,
        pickupAddress: widget.departureAddress,
        destinationLatitude: widget.destinationLatitude,
        destinationLongitude: widget.destinationLongitude,
        destinationAddress: widget.destinationAddress,
        vehicleCategoryId: widget.selectedCategory.id,
      );

      if (!mounted) return;

      setState(() {
        createdTrip = trip;
        isLoading = false;
      });

      print('===== COURSE CRÉÉE =====');
      print('ID : ${trip.id}');
      print('Statut : ${trip.status}');
      print('Prix : ${trip.estimatedPrice}');
      print('Distance : ${trip.distanceKm}');
      print('Durée : ${trip.estimatedDuration}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SearchingDriverPage(
            trip: trip,
          ),
        ),
      );

      // Pour le moment, on affiche simplement
      // la confirmation.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Course créée avec succès !',
          ),
        ),
      );
    } catch (e) {
      print(
        'Erreur création course : $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de commander la course : $e',
          ),
        ),
      );
    }
  }

  // =====================================================
  // INTERFACE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirmation',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Votre course',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // DÉPART
            // =================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 30,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Départ',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        widget.departureAddress,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // =================================================
            // DESTINATION
            // =================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 30,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Destination',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        widget.destinationAddress,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            // =================================================
            // CATÉGORIE
            // =================================================

            const Text(
              'Véhicule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.selectedCategory.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.selectedCategory
                          .description,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // =================================================
            // BOUTON COMMANDER
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : createTrip,

                child: isLoading
                    ? const SizedBox(
                        width: 25,
                        height: 25,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Commander la course',
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