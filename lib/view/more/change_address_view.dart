import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../../common/globs.dart';
import '../../common_widget/cart_icon.dart';

class ChangeAddressView extends StatefulWidget {
  const ChangeAddressView({super.key});

  @override
  State<ChangeAddressView> createState() => _ChangeAddressViewState();
}

class _ChangeAddressViewState extends State<ChangeAddressView> {
  GoogleMapController? _controller;
  final TextEditingController _searchController = TextEditingController();

  String _selectedAddress = "";
  Set<Marker> _markers = {};

  final locations = const [
    LatLng(14.5995, 120.9842), // Manila, Philippines
  ];

  late List<MarkerData> _customMarkers;

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(14.5995, 120.9842), // Manila, Philippines
      zoom: 14.151926040649414);

  @override
  void initState() {
    super.initState();
    _customMarkers = [
      MarkerData(
        marker: Marker(
            markerId: const MarkerId('id-1'), position: locations[0]),
        child: _customMarker('Everywhere\nis a Widgets', Colors.blue),
      ),
    ];
  }

  _customMarker(String symbol, Color color) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Image.asset(
            'assets/img/map_pin.png',
            width: 35,
            fit: BoxFit.contain,
          )
        ],
      ),
    );
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      );
      _selectedAddress = "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Location permissions are denied"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Location permissions are permanently denied"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Getting current location..."),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      _onMapTapped(currentLocation);

      // Move camera to current location
      if (_controller != null) {
        await _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 16.0),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Current location selected"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error getting location: $e"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmAddress() async {
    if (_selectedAddress.isNotEmpty) {
      try {
        // Save address to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_address', _selectedAddress);

        // Return the address to the previous screen
        if (mounted) {
          Navigator.pop(context, _selectedAddress);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Address updated: $_selectedAddress"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error saving address: $e"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        centerTitle: false,
        title: Text(
          "Change Address",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w800),
        ),

        actions: [
          const CartIcon(size: 25),
        ],
      ),
      body: CustomGoogleMapMarkerBuilder(
        customMarkers: _customMarkers,
        builder: (BuildContext context, Set<Marker>? markers) {
          if (markers == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading map..."),
                ],
              ),
            );
          }

          try {
            return Stack(
              children: [
                // Google Maps
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _kLake,
                  compassEnabled: false,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<PanGestureRecognizer>(
                      () => PanGestureRecognizer(),
                    ),
                  },
                  markers: _markers.isNotEmpty ? _markers : markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                  onTap: _onMapTapped,
                ),

                // Search overlay at the top
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search address field
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: RoundTextfield(
                            controller: _searchController,
                            hintText: "Search for address...",
                            left: Icon(Icons.search, color: TColor.primaryText),
                          ),
                        ),

                        // Current location button
                        InkWell(
                          onTap: _getCurrentLocation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.my_location, color: TColor.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Use current location",
                                    style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: TColor.primary,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Selected address display at bottom
                if (_selectedAddress.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: TColor.primary, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                "Selected Address",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedAddress,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _confirmAddress,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColor.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Confirm Address",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          } catch (e) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Map not available",
                    style: TextStyle(
                      fontSize: 18,
                      color: TColor.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please check your internet connection\nand Google Maps API configuration",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: TColor.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
