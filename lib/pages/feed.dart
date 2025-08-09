import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../design-system/colors.dart';
import '../design-system/text.dart';
import '../design-system/dropdown_textfield.dart';
import '../design-system/dropdown_button.dart';
import '../design-system/button.dart';
import '../design-system/text.dart';

import '../components/block.dart';
import '../components/navbar.dart';

import '../services/location_service.dart';
import '../services/auth_service.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final TextEditingController _locationController = TextEditingController();
  String _radius = '10mi';
  String _originalLocation = '';
  bool _isLoading = true;
  final bool _cityInSuggestions = true;
  final List<String> _typeAheadSuggestions = [];
  Timer? _debounceTimer;
  List<dynamic> _feedData = [];

  var miles = {'5mi': 5, '10mi': 10, '20mi': 20, '50mi': 50, '100mi': 100};

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        bool localCityInSuggestions = _cityInSuggestions;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlockTalkTypeAhead(
                    suggestions: _typeAheadSuggestions,
                    controller: _locationController,
                    optionInSuggestions: localCityInSuggestions,
                    optionInSuggestionsCallback: (value) {
                      setModalState(() => localCityInSuggestions = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  BlockTalkDropdownButton(
                    items: const ['5mi', '10mi', '20mi', '50mi', '100mi'],
                    onChanged: (value) {
                      _setRadius(value ?? '10mi');
                    },
                  ),
                  const SizedBox(height: 16),
                  BlockTalkButton(
                    text: "Apply Filters",
                    type: 'solid',
                    onPressed: () {
                      _retrieveFeed();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _fetchLocation() async {
    try {
      final (position, address) = await LocationService()
          .determinePositionAndAddress();
      String city = '${address.locality}, ${address.administrativeArea}';
      return city;
    } catch (e) {
      return 'Unable to fetch location: $e';
    }
  }

  void _setRadius(String value) {
    setState(() {
      _radius = value;
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    if (!mounted) return;

    try {
      final response = await http.get(
        Uri.parse('$backendUrl/retrieve-city?city=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> suggestions = jsonDecode(response.body);
        setState(() {
          _typeAheadSuggestions.clear();
          _typeAheadSuggestions.addAll(
            suggestions.map((s) => s.toString()).toList(),
          );
        });
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching suggestions: $e')));
    }
  }

  Future<void> _retrieveFeed() async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    try {
      final response = await http.get(
        Uri.parse(
          '$backendUrl/feed?location=${_locationController.text}&distance=${miles[_radius]}',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> feedData = jsonDecode(response.body);
        setState(() {
          _feedData = feedData;
        });
      } else {
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      print('Error fetching feed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching feed: $e')));
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchLocation().then((location) {
      if (location != null) {
        _locationController.text = location;
        _typeAheadSuggestions.add(location);
        _originalLocation = location;
        _retrieveFeed();
      } else {
        _locationController.text = 'Unknown Location';
      }
      setState(() {
        _isLoading = false;
      });
    });

    _locationController.addListener(() {
      if (_locationController.text != _originalLocation &&
          _locationController.text.length >= 3 &&
          _locationController.text.isNotEmpty) {
        if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          _fetchSuggestions(_locationController.text);
          _originalLocation = _locationController.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundColor),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: SizedBox(
                          width: 100,
                          child: BlockTalkButton(
                            text: "Filter",
                            type: 'outline',
                            onPressed: _showFilterSheet,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _feedData.length,
                      itemBuilder: (context, index) {
                        final feedItem = _feedData[index];
                        return Block(
                          blockId: feedItem['id'] ?? '',
                          blockText: feedItem['content'] ?? '',
                          name:
                              feedItem['first_name'] +
                                  ' ' +
                                  feedItem['last_name'] ??
                              '',
                          username: feedItem['username'] ?? '',
                          upvotes: feedItem['upvotes'] ?? 0,
                          downvotes: feedItem['downvotes'] ?? 0,
                          conversations: feedItem['number_of_comments'] ?? 69,
                          imageUrl:
                              'assets/images/default_avatar.png', // Placeholder image
                        );
                      },
                    ),
                  ),
                  Navbar(selectedIndex: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
