import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class TrackinglbsPage extends StatefulWidget {
  const TrackinglbsPage({super.key});

  @override
  State<TrackinglbsPage> createState() => _TrackinglbsPageState();
}

class _TrackinglbsPageState extends State<TrackinglbsPage> {
  // Change default location to your preferred city or location
  LatLng _currentPosition = LatLng(-7.7956, 110.3695); // Default Yogyakarta
  LatLng? _destinationPosition;
  final MapController _mapController = MapController();
  double _currentZoom = 16.0;
  bool _isNavigating = false;
  List<LatLng> _routePoints = [];
  
  // Theme colors
  final Color primaryColor = const Color.fromARGB(255, 89, 0, 185); // Purple
  final Color secondaryColor = const Color(0xFF6A11CB); // Light Purple
  final Color accentColor = const Color.fromARGB(255, 173, 110, 241); // Lighter Purple
  final Color textColor = Colors.white;
  
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;
  final Duration _searchDebounceTime = const Duration(milliseconds: 500);
  final Map<String, List<Map<String, dynamic>>> _searchCache = {};
  
  // Location tracking
  late StreamSubscription<Position> _positionStream;
  bool _isTracking = true;
  bool _isLocationLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10, // meters
    );
    
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      if (_isTracking) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          if (!_isNavigating) {
            _mapController.move(_currentPosition, _currentZoom);
          }
        });
        
        // Update route if navigating
        if (_isNavigating && _destinationPosition != null) {
          _getRoute();
        }
      }
    });
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLocationLoading = true;
    });
    
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Aktifkan layanan lokasi"),
            backgroundColor: primaryColor,
          ),
        );
      }
      setState(() {
        _isLocationLoading = false;
      });
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Izin lokasi ditolak"),
              backgroundColor: primaryColor,
            ),
          );
        }
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }
    }

    try {
      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, _currentZoom);
        _isLocationLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error mendapatkan lokasi: $e"),
            backgroundColor: primaryColor,
          ),
        );
      }
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(3.0, 18.0);
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(3.0, 18.0);
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // Check cache first
    if (_searchCache.containsKey(query)) {
      setState(() {
        _searchResults = _searchCache[query]!;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Try Nominatim first
      final nominatimResponse = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}'
          '&format=json&limit=5&addressdetails=1&countrycodes=id&polygon_geojson=1',
        ),
        headers: {'User-Agent': 'TrackingLBSApp'},
      ).timeout(const Duration(seconds: 3));

      if (nominatimResponse.statusCode == 200) {
        List<dynamic> data = jsonDecode(nominatimResponse.body);
        List<Map<String, dynamic>> results = [];

        for (var item in data) {
          results.add({
            'display_name': item['display_name'],
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
            'address': item['address'],
            'importance': item['importance'] ?? 0.0,
          });
        }

        // Sort by importance (higher importance = better match)
        results.sort((a, b) => (b['importance'] as double).compareTo(a['importance'] as double));

        setState(() {
          _searchResults = results.take(5).toList(); // Limit to top 5 results
          _isSearching = false;
        });

        // Cache the results
        _searchCache[query] = _searchResults;
      } else {
        // Fallback to another service if Nominatim fails
        await _fallbackSearch(query);
      }
    } catch (e) {
      // Try fallback if primary search fails
      await _fallbackSearch(query);
    }
  }

  Future<void> _fallbackSearch(String query) async {
    try {
      // Example using Mapbox API (replace with your actual token)
      const mapboxToken = 'pk.yourmapboxtoken';
      final response = await http.get(
        Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json'
          '?access_token=$mapboxToken'
          '&country=ID&limit=5',
        ),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> results = [];

        for (var feature in data['features']) {
          results.add({
            'display_name': feature['place_name'],
            'lat': feature['center'][1].toDouble(),
            'lon': feature['center'][0].toDouble(),
            'address': {
              'city': feature['context']?.firstWhere(
                (ctx) => ctx['id'].toString().contains('place'),
                orElse: () => null,
              )?['text'],
            },
          });
        }

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });

        // Cache the results
        _searchCache[query] = _searchResults;
      } else {
        throw Exception('Fallback search failed');
      }
    } catch (e) {
      setState(() {
        _searchResults = [{
          'display_name': 'Pencarian tidak tersedia saat ini',
          'error': true
        }];
        _isSearching = false;
      });
    }
  }

  String _formatAddress(Map<String, dynamic> location) {
    if (location.containsKey('error')) return location['display_name'];
    
    if (location.containsKey('address')) {
      final address = location['address'];
      List<String> parts = [];
      
      // Build address from most specific to least specific
      if (address['road'] != null) parts.add(address['road']);
      if (address['neighbourhood'] != null) parts.add(address['neighbourhood']);
      if (address['suburb'] != null) parts.add(address['suburb']);
      if (address['village'] != null) parts.add(address['village']);
      if (address['city'] != null) parts.add(address['city']);
      if (address['state'] != null) parts.add(address['state']);
      
      // If we don't have enough details, use the full display name
      if (parts.length < 2 && location['display_name'] != null) {
        return location['display_name'].toString().split(',').take(3).join(', ');
      }
      
      return parts.join(', ');
    }
    
    // For Mapbox results
    if (location['display_name'] != null) {
      return location['display_name'].toString().split(',').take(3).join(', ');
    }
    
    return 'Lokasi tidak diketahui';
  }

  String _getLocationSubtitle(Map<String, dynamic> result) {
    if (result.containsKey('error')) return '';
    
    if (result['address'] is Map) {
      final address = result['address'] as Map;
      if (address['city'] != null && address['state'] != null) {
        return '${address['city']}, ${address['state']}';
      }
      if (address['city'] != null) return address['city'].toString();
      if (address['state'] != null) return address['state'].toString();
    }
    return result['display_name']?.toString().split(',').skip(1).take(2).join(',') ?? '';
  }

  void _setDestination(Map<String, dynamic> location) {
    if (location.containsKey('lat') && location.containsKey('lon')) {
      setState(() {
        _destinationPosition = LatLng(location['lat'], location['lon']);
        _searchController.text = _formatAddress(location);
        _searchResults = [];
        _isTracking = false; // Stop automatic tracking when destination is set
      });
      
      _getRoute();
    }
  }

  Future<void> _getRoute() async {
    if (_currentPosition == null || _destinationPosition == null) return;
    
    setState(() {
      _isNavigating = true;
    });

    try {
      // Use OSRM API for routing
      final response = await http.get(
        Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/'
          '${_currentPosition.longitude},${_currentPosition.latitude};'
          '${_destinationPosition!.longitude},${_destinationPosition!.latitude}'
          '?overview=full&geometries=geojson',
        ),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok') {
          List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
          List<LatLng> routePoints = coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          setState(() {
            _routePoints = routePoints;
          });
          
          _fitRouteOnMap();
        }
      } else {
        throw Exception('Failed to load route');
      }
    } catch (e) {
      // Fallback to simple route if API fails
      List<LatLng> route = _generateSimpleRoute(_currentPosition, _destinationPosition!);
      setState(() {
        _routePoints = route;
      });
      _fitRouteOnMap();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Menggunakan rute perkiraan: $e"),
            backgroundColor: primaryColor,
          ),
        );
      }
    }
  }

  List<LatLng> _generateSimpleRoute(LatLng start, LatLng end) {
    List<LatLng> points = [];
    points.add(start);
    
    // Create intermediate points to make it look like a route
    double latStep = (end.latitude - start.latitude) / 10;
    double lngStep = (end.longitude - start.longitude) / 10;
    
    for (int i = 1; i < 10; i++) {
      points.add(LatLng(
        start.latitude + latStep * i,
        start.longitude + lngStep * i,
      ));
    }
    
    points.add(end);
    return points;
  }

  void _fitRouteOnMap() {
    if (_routePoints.isEmpty) return;
    
    // Get bounds of all points in the route
    double minLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    
    // Add some padding
    minLat -= 0.01;
    maxLat += 0.01;
    minLng -= 0.01;
    maxLng += 0.01;
    
    // Calculate center and zoom
    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;
    
    // Calculate zoom level based on the distance
    double distance = const Distance().distance(_currentPosition, _destinationPosition!);
    double zoom = 16.0;
    
    if (distance > 5000) zoom = 12.0;
    else if (distance > 2000) zoom = 13.0;
    else if (distance > 1000) zoom = 14.0;
    else if (distance > 500) zoom = 15.0;
    
    // Move map to fit route
    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  void _cancelNavigation() {
    setState(() {
      _isNavigating = false;
      _routePoints = [];
      _destinationPosition = null;
      _searchController.text = "";
      _isTracking = true; // Resume automatic tracking
      _mapController.move(_currentPosition, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tracking Maps",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Cari lokasi tujuan...",
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (value) {
                          if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
                          
                          _searchDebounce = Timer(_searchDebounceTime, () {
                            if (value.isNotEmpty) {
                              _searchLocation(value);
                            } else {
                              setState(() {
                                _searchResults = [];
                              });
                            }
                          });
                        },
                      ),
                    ),
                    if (_isNavigating)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: _cancelNavigation,
                      ),
                  ],
                ),
              ),
              
              // Search results
              if (_searchResults.isNotEmpty)
                Container(
                  height: _searchResults.length > 3 ? 200 : null,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: _isSearching
                      ? Center(child: CircularProgressIndicator(color: secondaryColor))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return Card(
                              margin: const EdgeInsets.all(4),
                              child: ListTile(
                                leading: Icon(Icons.location_on, color: secondaryColor),
                                title: Text(
                                  _formatAddress(result),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  _getLocationSubtitle(result),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  if (!result.containsKey('error')) {
                                    _setDestination(result);
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                )
              else if (_isSearching)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: secondaryColor),
                        const SizedBox(height: 8),
                        const Text("Mencari lokasi..."),
                      ],
                    ),
                  ),
                )
              else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text("Tidak ada hasil ditemukan"),
                  ),
                ),
              
              // Map
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _currentPosition,
                        zoom: _currentZoom,
                        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.tracking_lbs',
                        ),
                        
                        // Current location marker
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition,
                              width: 40,
                              height: 40,
                              builder: (ctx) => Container(
                                decoration: BoxDecoration(
                                  color: secondaryColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: CircleAvatar(
                                  backgroundColor: primaryColor,
                                  child: Icon(
                                    Icons.navigation,
                                    color: textColor,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Route polyline
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                color: accentColor.withOpacity(0.7),
                                strokeWidth: 5.0,
                              ),
                            ],
                          ),
                        
                        // Destination marker
                        if (_destinationPosition != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _destinationPosition!,
                                width: 40,
                                height: 40,
                                builder: (ctx) => Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    
                    // Zoom controls
                    Positioned(
                      bottom: 100,
                      right: 25,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(
                            heroTag: "zoomIn",
                            mini: true,
                            backgroundColor: secondaryColor,
                            onPressed: _zoomIn,
                            child: Icon(Icons.add, color: textColor),
                          ),
                          const SizedBox(height: 15),
                          FloatingActionButton(
                            heroTag: "zoomOut",
                            mini: true,
                            backgroundColor: accentColor,
                            onPressed: _zoomOut,
                            child: Icon(Icons.remove, color: textColor),
                          ),
                        ],
                      ),
                    ),
                    
                    // Navigation info panel
                    if (_isNavigating && _destinationPosition != null)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 70,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.navigation, color: primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Navigasi aktif",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _searchController.text,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _cancelNavigation,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],  
          ),
          
          // Loading indicator for initial location
          if (_isLocationLoading)
            Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          setState(() {
            _isTracking = true; // Resume tracking when button is pressed
          });
          _mapController.move(_currentPosition, _currentZoom);
        },
        child: Icon(Icons.my_location, color: textColor),
      ),
    );
  }
}