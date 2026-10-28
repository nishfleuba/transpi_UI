import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/trip.dart';
import 'driver_trip_page.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  List<dynamic> trips = [];
  bool isLoading = true;
  String? errorMessage;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _loadAvailableTrips();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadAvailableTrips(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAvailableTrips() async {
    try {
        final data = await ApiService.getAvailableTrips();
        print('===== COURSES DISPONIBLES =====');
        print(data);
        print('Nombre de courses : ${data.length}');

        if (!mounted) return;

        setState(() {
        trips = data;
        isLoading = false;
        errorMessage = null;
        });
    } catch (e) {
        if (!mounted) return;

        setState(() {
        isLoading = false;
        errorMessage = e.toString();
        });

        debugPrint('ERREUR AVAILABLE TRIPS: $e');
    }
    }

  Future<void> _acceptTrip(int tripId) async {
    try {
      final Trip acceptedTrip = await ApiService.acceptTrip(tripId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course acceptée avec succès !'),
        ),
      );

      // Arrêter l'actualisation automatique
      _timer?.cancel();

      // Aller vers l'écran de gestion de la course
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DriverTripPage(
            trip: acceptedTrip,
          ),
        ),
      );
    } catch (e) {
      debugPrint('ERREUR ACCEPTATION: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d\'accepter cette course. '
            'Elle a peut-être déjà été prise.',
          ),
        ),
      );

      // Actualiser la liste après l'erreur
      await _loadAvailableTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace chauffeur'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAvailableTrips,
              child: const Text('RÉESSAYER'),
            ),
          ],
        ),
      );
    }

    if (trips.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAvailableTrips,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text(
                'Aucune course disponible pour le moment.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAvailableTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];

          return _buildTripCard(trip);
        },
      ),
    );
  }

  Widget _buildTripCard(dynamic trip) {
    final int tripId = trip['id'];

    final String pickup =
        trip['pickup_address'] ?? 'Départ inconnu';

    final String destination =
        trip['destination_address'] ?? 'Destination inconnue';

    final String price =
        trip['estimated_price']?.toString() ?? '0.00';

    final String distance =
        trip['distance_to_pickup']?.toString() ?? '0.00';

    final String tripDistance =
        trip['distance_km']?.toString() ?? '0.00';

    final String duration =
        trip['estimated_duration']?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course #$tripId',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.my_location),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pickup,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    destination,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _info(
                  'Prix',
                  price,
                ),
                _info(
                  'Course',
                  '$tripDistance km',
                ),
                _info(
                  'Durée',
                  '$duration min',
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'À $distance km du départ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _acceptTrip(tripId),
                child: const Text(
                  'ACCEPTER LA COURSE',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}