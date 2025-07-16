import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';

import '../design-system/colors.dart';

import '../components/navbar.dart';

import '../services/auth_service.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  Timer? _debounceTimer;
  LatLngBounds? _lastBounds;
  List<Marker> _markers = [];
  MapController _mapController = MapController();

  static const Duration debounceDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  static const String mapTilerApiKey = String.fromEnvironment(
    'MAPTILER_API_KEY',
    defaultValue: 'YOUR_MAPTILER_API_KEY',
  );

  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return ("${place.street}, ${place.locality}, ${place.country}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _retrieveEntriesWithinBounds() async {
    AuthService authService = AuthService();
    String? accessToken = await authService.getAccessToken();

    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    final url = Uri.parse('$backendUrl/retrieve-entries-within-visible-bounds');

    final bounds = {
      'north': _lastBounds?.north,
      'south': _lastBounds?.south,
      'east': _lastBounds?.east,
      'west': _lastBounds?.west,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken.toString(),
      },
      body: json.encode(bounds),
    );

    if (response.statusCode == 200) {
      final List<dynamic> entries = json.decode(response.body);
      final List<Marker> markers = [];

      for (var entry in entries) {
        final marker = Marker(
          point: LatLng(entry['latitude'], entry['longitude']),
          width: 40.0,
          height: 40.0,
          child: Icon(Icons.location_on, color: Colors.red, size: 40.0),
        );
        markers.add(marker);
      }
      setState(() {
        _markers = markers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(28.526540, -81.199780),
                  initialZoom: 13.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                  onPositionChanged: (MapCamera camera, bool hasGesture) {
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(debounceDuration, () {
                      final bounds = camera.visibleBounds;

                      if (_lastBounds != bounds) {
                        _lastBounds = bounds;
                        _retrieveEntriesWithinBounds();
                      }
                    });
                  },
                onTap: (tapPosition, point) async {
                  // `point` is a LatLng
                  String? address = await getAddressFromLatLng(
                    point.latitude,
                    point.longitude,
                  );
                  context.goNamed(
                    'add_entry',
                    queryParameters: {
                      'latitude': point.latitude.toString(),
                      'longitude': point.longitude.toString(),
                      'address': address ?? '',
                    }
                  );
                },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$mapTilerApiKey',
                    userAgentPackageName: 'taher.blocktalk.app',
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright'),
                        ),
                      ),
                    ],
                  ),
                  MarkerLayer(markers: _markers),
                ],

              ),
            ),
            Navbar(selectedIndex: 1),
          ],
        ),
      ),
    );
  }
}
