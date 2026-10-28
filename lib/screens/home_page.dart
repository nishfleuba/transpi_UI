import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'destination_map_page.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final destinationController = TextEditingController();
  Position? currentPosition;
  bool isLoadingLocation = true;
  bool isGeocoding = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() => isLoadingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() => isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() => isLoadingLocation = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() {
        currentPosition = position;
        isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingLocation = false);
    }
  }

  Future<void> searchDestination() async {
    final destination = destinationController.text.trim();
    
    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une destination.')),
      );
      return;
    }

    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre position actuelle est indisponible.')),
      );
      return;
    }

    setState(() => isGeocoding = true);

    try {
      // Récupérer l'adresse du départ
      final pickupResult = await ApiService.reverseGeocode(
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
      );
      final pickupAddress = pickupResult['address'].toString();

      // Géocoder la destination
      final result = await ApiService.geocodeAddress(destination);
      final latitude = double.parse(result['latitude'].toString());
      final longitude = double.parse(result['longitude'].toString());
      final address = result['address'].toString();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DestinationMapPage(
            departureLatitude: currentPosition!.latitude,
            departureLongitude: currentPosition!.longitude,
            departureAddress: pickupAddress,
            destinationAddress: address,
            destinationLatitude: latitude,
            destinationLongitude: longitude,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de préparer le trajet : $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isGeocoding = false);
      }
    }
  }

  void _showReservationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réserver un trajet'),
        content: const Text('Cette fonctionnalité sera bientôt disponible. Vous pourrez planifier vos courses à l\'avance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showCommanderModal() {
    destinationController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Où allez-vous ?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Champ de recherche
            TextField(
              controller: destinationController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Entrez votre destination',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isGeocoding
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          Navigator.pop(context);
                          searchDestination();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onSubmitted: (value) {
                Navigator.pop(context);
                searchDestination();
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Destinations récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Liste des destinations récentes
            _buildRecentDestinationModal('Université du Burundi'),
            const SizedBox(height: 10),
            _buildRecentDestinationModal('Centre-ville'),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDestinationModal(String destination) {
    return InkWell(
      onTap: () {
        destinationController.text = destination;
        Navigator.pop(context);
        searchDestination();
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                destination,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRANSPI'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (String choice) async {
              if (choice == 'logout') {
                // Afficher une confirmation
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Déconnexion'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Déconnexion'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),
            const Text(
              'Bonjour 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                hintText: 'Où allez-vous ?',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isGeocoding
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: searchDestination,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onSubmitted: (_) => searchDestination(),
            ),

            const SizedBox(height: 35),

            const Text(
              'Que voulez-vous faire ?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.directions_car,
                    title: 'Commander',
                    subtitle: 'Course immédiate\nmaintenant',
                    onTap: () {
                      _showCommanderModal();
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.calendar_month,
                    title: 'Réserver',
                    subtitle: 'Planifier pour\nplus tard',
                    onTap: () {
                      _showReservationDialog();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            const Text(
              'Destinations récentes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildRecentDestination(
              'Université du Burundi',
            ),

            const SizedBox(height: 10),

            _buildRecentDestination(
              'Centre-ville',
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Activités',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Compte',
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 45,
              color: Colors.blue,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDestination(String destination) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [

          const Icon(
            Icons.history,
            size: 28,
          ),

          const SizedBox(width: 15),

          Text(
            destination,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}