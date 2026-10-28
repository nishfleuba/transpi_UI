import 'package:flutter/material.dart';
import '../models/vehicle_category.dart';
import '../services/api_service.dart';
import 'confirmation_page.dart';

class CategoriesPage extends StatefulWidget {
  final double departureLatitude;
  final double departureLongitude;
  final String departureAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationAddress;

  const CategoriesPage({
    super.key,
    required this.departureLatitude,
    required this.departureLongitude,
    required this.departureAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationAddress,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<VehicleCategory> categories = [];

  VehicleCategory? selectedCategory;

  @override
  void initState() {
    super.initState();

    print('===== TRAJET REÇU =====');

    print(
      'Adresse départ : ${widget.departureAddress}',
    );

    print(
      'Départ latitude : ${widget.departureLatitude}',
    );

    print(
      'Départ longitude : ${widget.departureLongitude}',
    );

    print(
      'Adresse destination : ${widget.destinationAddress}',
    );

    print(
      'Destination latitude : '
      '${widget.destinationLatitude}',
    );

    print(
      'Destination longitude : '
      '${widget.destinationLongitude}',
    );

    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final result =
          await ApiService.getVehicleCategories();

      if (!mounted) return;

      setState(() {
        categories = result;
      });
    } catch (e) {
      print('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,

              itemBuilder: (context, index) {
                final category = categories[index];

                final isSelected =
                    selectedCategory?.id == category.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },

                  child: Card(
                    margin: const EdgeInsets.all(10),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            category.description,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Prix de base : '
                            '${category.basePrice}',
                          ),

                          Text(
                            'Prix / km : '
                            '${category.pricePerKm}',
                          ),

                          Text(
                            'Prix / minute : '
                            '${category.pricePerMinute}',
                          ),

                          Text(
                            'Frais de service : '
                            '${category.serviceFee}',
                          ),

                          Text(
                            'Passagers maximum : '
                            '${category.maxPassengers}',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: selectedCategory == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ConfirmationPage(
                              departureLatitude:
                                  widget.departureLatitude,

                              departureLongitude:
                                  widget.departureLongitude,

                              departureAddress:
                                  widget.departureAddress,

                              destinationLatitude:
                                  widget.destinationLatitude,

                              destinationLongitude:
                                  widget.destinationLongitude,

                              destinationAddress:
                                  widget.destinationAddress,

                              selectedCategory:
                                  selectedCategory!,
                            ),
                          ),
                        );
                      },

                child: const Text(
                  'Continuer',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}