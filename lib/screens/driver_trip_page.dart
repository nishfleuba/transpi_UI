import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/api_service.dart';

class DriverTripPage extends StatefulWidget {
  final Trip trip;

  const DriverTripPage({
    super.key,
    required this.trip,
  });

  @override
  State<DriverTripPage> createState() => _DriverTripPageState();
}

class _DriverTripPageState extends State<DriverTripPage> {
  late Trip trip;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
  }

  Future<void> _arrived() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final updatedTrip = await ApiService.arrivedTrip(trip.id);

      if (!mounted) return;

      setState(() {
        trip = updatedTrip;
        isProcessing = false;
      });

      _showMessage('Vous êtes arrivé au point de départ.');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      _showMessage(
        'Impossible de signaler votre arrivée.',
        error: true,
      );
    }
  }

  Future<void> _startTrip() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final updatedTrip = await ApiService.startTrip(trip.id);

      if (!mounted) return;

      setState(() {
        trip = updatedTrip;
        isProcessing = false;
      });

      _showMessage('Course démarrée.');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      _showMessage(
        'Impossible de démarrer la course.',
        error: true,
      );
    }
  }

  Future<void> _completeTrip() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final updatedTrip = await ApiService.completeTrip(trip.id);

      if (!mounted) return;

      setState(() {
        trip = updatedTrip;
        isProcessing = false;
      });

      _showMessage('Course terminée avec succès.');

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      _showMessage(
        'Impossible de terminer la course.',
        error: true,
      );
    }
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course #${trip.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),

            const SizedBox(height: 20),

            _buildRouteCard(),

            const SizedBox(height: 20),

            _buildTripInformation(),

            const SizedBox(height: 30),

            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    String title;
    IconData icon;

    switch (trip.status) {
      case 'DRIVER_ASSIGNED':
        title = 'Course acceptée';
        icon = Icons.check_circle;
        break;

      case 'DRIVER_ARRIVED':
        title = 'Vous êtes arrivé';
        icon = Icons.location_on;
        break;

      case 'IN_PROGRESS':
        title = 'Course en cours';
        icon = Icons.directions_car;
        break;

      case 'COMPLETED':
        title = 'Course terminée';
        icon = Icons.flag;
        break;

      default:
        title = trip.status;
        icon = Icons.info;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itinéraire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.my_location),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Départ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(trip.pickupAddress),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Destination',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(trip.destinationAddress),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _infoRow(
              'Distance',
              '${trip.distanceKm} km',
            ),
            const Divider(),
            _infoRow(
              'Durée estimée',
              '${trip.estimatedDuration} min',
            ),
            const Divider(),
            _infoRow(
              'Prix',
              '${trip.estimatedPrice}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (trip.status == 'DRIVER_ASSIGNED') {
      return _actionButton(
        label: 'JE SUIS ARRIVÉ',
        icon: Icons.location_on,
        onPressed: _arrived,
      );
    }

    if (trip.status == 'DRIVER_ARRIVED') {
      return _actionButton(
        label: 'DÉMARRER LA COURSE',
        icon: Icons.play_arrow,
        onPressed: _startTrip,
      );
    }

    if (trip.status == 'IN_PROGRESS') {
      return _actionButton(
        label: 'TERMINER LA COURSE',
        icon: Icons.flag,
        onPressed: _completeTrip,
      );
    }

    if (trip.status == 'COMPLETED') {
      return const Center(
        child: Text(
          'Course terminée.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : onPressed,
        icon: isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}