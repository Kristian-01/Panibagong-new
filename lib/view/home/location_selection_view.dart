import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '/common/color_extension.dart';

class LocationSelectionView extends StatefulWidget {
  const LocationSelectionView({super.key});

  @override
  State<LocationSelectionView> createState() => _LocationSelectionViewState();
}

class _LocationSelectionViewState extends State<LocationSelectionView> {
  GoogleMapController? mapController;
  LatLng currentPosition = const LatLng(14.5995, 120.9842); // Manila default
  String selectedAddress = "Loading...";
  bool isLoading = true;
  Set<Marker> markers = {};
  TextEditingController searchController = TextEditingController();

  // Popular locations in Metro Manila
  final List<Map<String, dynamic>> popularLocations = [
    {
      'name': 'Makati City',
      'address': 'Makati, Metro Manila, Philippines',
      'lat': 14.5547,
      'lng': 121.0244,
    },
    {
      'name': 'BGC Taguig',
      'address': 'Bonifacio Global City, Taguig, Metro Manila',
      'lat': 14.5515,
      'lng': 121.0512,
    },
    {
      'name': 'Ortigas Center',
      'address': 'Ortigas Center, Pasig, Metro Manila',
      'lat': 14.5866,
      'lng': 121.0611,
    },
    {
      'name': 'Quezon City',
      'address': 'Quezon City, Metro Manila, Philippines',
      'lat': 14.6760,
      'lng': 121.0437,
    },
    {
      'name': 'Manila City',
      'address': 'Manila, Metro Manila, Philippines',
      'lat': 14.5995,
      'lng': 120.9842,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          selectedAddress = "Location services are disabled";
          isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            selectedAddress = "Location permissions are denied";
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          selectedAddress = "Location permissions are permanently denied";
          isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      
      setState(() {
        currentPosition = newPosition;
        markers = {
          Marker(
            markerId: const MarkerId('current'),
            position: newPosition,
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        };
      });

      await _getAddressFromLatLng(newPosition);
      
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newPosition, zoom: 16),
          ),
        );
      }
    } catch (e) {
      setState(() {
        selectedAddress = "Error getting location: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        
        setState(() {
          selectedAddress = address.isNotEmpty ? address : "Unknown location";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = "Error getting address";
        isLoading = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);
        
        setState(() {
          currentPosition = newPosition;
          markers = {
            Marker(
              markerId: const MarkerId('searched'),
              position: newPosition,
              infoWindow: InfoWindow(title: query),
            ),
          };
        });

        await _getAddressFromLatLng(newPosition);
        
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: newPosition, zoom: 16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not found: $e')),
        );
      }
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      currentPosition = position;
      markers = {
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      };
    });
    _getAddressFromLatLng(position);
  }

  void _selectPopularLocation(Map<String, dynamic> location) {
    LatLng position = LatLng(location['lat'], location['lng']);
    setState(() {
      currentPosition = position;
      selectedAddress = location['address'];
      isLoading = false;
      markers = {
        Marker(
          markerId: const MarkerId('popular'),
          position: position,
          infoWindow: InfoWindow(title: location['name']),
        ),
      };
    });

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 16),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: TColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => searchController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.primary),
                ),
              ),
              onSubmitted: _searchLocation,
            ),
          ),

          // Popular Locations
          Container(
            height: 120,
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Popular Locations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TColor.primaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: popularLocations.length,
                    itemBuilder: (context, index) {
                      final location = popularLocations[index];
                      return GestureDetector(
                        onTap: () => _selectPopularLocation(location),
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: TColor.primary,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                location['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: TColor.primaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: currentPosition,
                zoom: 16,
              ),
              markers: markers,
              onTap: _onMapTap,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
            ),
          ),
          
          // Address Display and Confirm Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Address:',
                  style: TextStyle(
                    fontSize: 14,
                    color: TColor.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLoading ? 'Loading...' : selectedAddress,
                  style: TextStyle(
                    fontSize: 16,
                    color: TColor.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () {
                      Navigator.pop(context, selectedAddress);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
