import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/screens/building_info_screen.dart';

class AddressConfirmationScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  
  const AddressConfirmationScreen({super.key, this.onComplete});

  @override
  ConsumerState<AddressConfirmationScreen> createState() =>
      _AddressConfirmationScreenState();
}

class _AddressConfirmationScreenState
    extends ConsumerState<AddressConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocode();
    });
  }

  Future<void> _reverseGeocode() async {
    final building = ref.read(buildingProvider);
    if (building == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Add timeout to prevent hanging
      final placemarks = await placemarkFromCoordinates(
        building.latitude,
        building.longitude,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return <Placemark>[];
        },
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() {
          _addressController.text = place.street ?? '';
          _postalCodeController.text = place.postalCode ?? '';
          _cityController.text = place.locality ?? place.administrativeArea ?? '';
          _districtController.text = place.subAdministrativeArea ?? '';
          _neighborhoodController.text = place.subLocality ?? '';
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final building = ref.read(buildingProvider);
    if (building == null) return;

    try {
      await ref.read(buildingProvider.notifier).updateBuilding({
        'addressLine': _addressController.text,
        'postalCode': _postalCodeController.text,
        'city': _cityController.text,
        'district': _districtController.text,
        'neighborhood': _neighborhoodController.text,
      });

      if (mounted) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const BuildingInfoScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Address'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading address...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Simple header
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Confirm Address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Form fields
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Street Address',
                          hintText: 'Enter street address',
                          prefixIcon: const Icon(Icons.home_rounded),
                          suffixIcon: _addressController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _addressController.clear();
                                  },
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _postalCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Postal Code',
                                prefixIcon: Icon(Icons.mail_rounded),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City *',
                                prefixIcon: Icon(Icons.location_city_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _districtController,
                        decoration: const InputDecoration(
                          labelText: 'District',
                          prefixIcon: Icon(Icons.map_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _neighborhoodController,
                        decoration: const InputDecoration(
                          labelText: 'Neighborhood',
                          prefixIcon: Icon(Icons.my_location_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }
}

