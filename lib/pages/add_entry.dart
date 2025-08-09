import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../design-system/button.dart';
import '../design-system/colors.dart';
import '../design-system/text.dart';
import "../design-system/dropdown_textfield.dart";
import '../components/navbar.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class AddEntryPage extends ConsumerStatefulWidget {
  final String? latitude;
  final String? longitude;
  final String? address;
  const AddEntryPage({
    super.key,
    this.latitude,
    this.longitude,
    this.address,});

  @override
  ConsumerState<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends ConsumerState<AddEntryPage> {
  late TextEditingController _titleController;
  TextEditingController _locationController = TextEditingController();
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  final List<dynamic> _addressSuggestions = [];
  final List<String> _suggestions = [];
  int _lastProcessedLength =
      0; // To track the last processed length of the location input. Every 3 characters, we will fetch suggestions.

  Position? _currentPosition;
  late bool _locationControllerTextInSuggestions;


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagController = TextEditingController();

    _locationController.text = widget.address ?? '';

    if (_locationController.text.isNotEmpty) {
      _fetchSuggestions(_locationController.text);
    }

    _locationControllerTextInSuggestions = widget.address != null &&
        widget.address!.isNotEmpty &&
        _suggestions.contains(widget.address);

    _locationController.addListener(() {
      final currentLength = _locationController.text.length;

      if (currentLength - _lastProcessedLength >= 3) {
        _fetchSuggestions(_locationController.text);
        _lastProcessedLength = currentLength;
      }

      if (currentLength < _lastProcessedLength) {
        _lastProcessedLength = currentLength;
      }
    });
  }

  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'Single Family',
    'Multi Family',
    'Commercial',
    'Industrial',
    'Construction Started',
    'Construction Completed',
    'Lot For Sale',
    'Lot Sold',
  ];

  Future<void> _fetchSuggestions(String query) async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    final url = Uri.parse('$backendUrl/autocomplete-address?query=$query');

    String? accessToken = await AuthService().getAccessToken();

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken.toString(),
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> backendResponseSuggestions = json.decode(
        response.body,
      );
      setState(() {
        _addressSuggestions.clear();
        _addressSuggestions.addAll(backendResponseSuggestions);
        _suggestions.clear();
        _suggestions.addAll(
          backendResponseSuggestions
              .map((suggestion) => suggestion['address'] as String)
              .toList(),
        );
      });

      print('Suggestions fetched successfully: $_suggestions');
    } else {
      print('Failed to fetch suggestions: ${response.statusCode}');
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _submitEntry() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (_locationControllerTextInSuggestions &&
        !_suggestions.contains(location)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a valid location')));
      return;
    }

    if (title.isEmpty || location.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    AuthService authService = AuthService();

    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    final url = Uri.parse('$backendUrl/create-entry');

    final entryData = {
      'title': title,
      'location': location,
      'description': description,
      'tags': _selectedTags,
      'latitude': _currentPosition?.latitude,
      'longitude': _currentPosition?.longitude,
    };

    String? accessToken = await authService.getAccessToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken.toString(),
      },
      body: entryData.isNotEmpty ? json.encode(entryData) : null,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Entry submitted successfully')));
      // Clear the fields after submission
      _titleController.clear();
      _locationController.clear();
      _descriptionController.clear();
      _selectedTags.clear();
      _currentPosition = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit entry: ${response.body}')),
      );
    }
  }

  void _setCurrentPosition(Position position) {
    setState(() {
      _currentPosition = position;
    });
  }

  Future<String> _determinePositionAndAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check and request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition();

    _setCurrentPosition(position);

    // Reverse geocoding
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];

    // Create a readable address
    String address =
        '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

    return address;
  }

  // If someone backspaces the location input, we need to reset the suggestions
  void _resetLocationController() {
    _locationController.clear();
    _lastProcessedLength = 0;
    _addressSuggestions.clear();
    _suggestions.clear();
  }

  // This function finds the coordinates from the address suggestions
  void _setCoordinatesFromAddress(String address) {
    for (var suggestion in _addressSuggestions) {
      if (suggestion['address'] == address) {
        double latitude = suggestion['lat'];
        double longitude = suggestion['lon'];
        _setCurrentPosition(
          Position(
            latitude: latitude,
            longitude: longitude,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          ),
        );
      }
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _showTagSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(void Function()) setStateDialog,
              ) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: BlockTalkText(
                    text: "Select Tags",
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _availableTags.map((tag) {
                            return FilterChip(
                              backgroundColor: Colors.white,
                              label: Text(tag),
                              selected: _selectedTags.contains(tag),
                              selectedColor: AppColors.primaryButtonColor
                                  .withOpacity(0.3),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.add(tag);
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                });
                                setStateDialog(() {});
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Done'),
                    ),
                  ],
                );
              },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundColor),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: BlockTalkText(
                  text: "Please login to add an entry",
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Navbar(selectedIndex: 2),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                top: true,
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlockTalkText(
                        text: "Add Entry",
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8),
                      BlockTalkText(
                        text:
                            "Share what you found and help others stay informed",
                        fontSize: 16.0,
                      ),
                      SizedBox(height: 24),

                      BlockTalkText(
                        text: "Title",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Enter a descriptive title',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Location Field
                      BlockTalkText(
                        text: "Location",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 8),
                      BlockTalkTypeAhead(
                        suggestions: _suggestions,
                        controller: _locationController,
                        selectedCallbacks: [
                          _setCoordinatesFromAddress,
                        ],
                        optionInSuggestions: _locationControllerTextInSuggestions,
                        optionInSuggestionsCallback: (value) {
                          print("Value changed: $value");
                          setState(() {
                            _locationControllerTextInSuggestions = value;
                          });
                        },
                      ),
                      SizedBox(height: 8),
                      BlockTalkButton(
                        text: "Get Current Location",
                        type: "outline",
                        buttonColor: AppColors.primaryButtonColor,
                        onPressed: () {
                          LocationService().determinePositionAndAddress()
                              .then((result) {
                                final (Position position, Placemark place) = result;
                                String address =
                                    '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
                                _setCurrentPosition(position);
                                setState(() {
                                  _locationController.text = address;
                                  _locationControllerTextInSuggestions = _suggestions.contains(address);
                                });
                              })
                              .catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Error getting location: $error",
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BlockTalkText(
                            text: "Tags",
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          TextButton.icon(
                            onPressed: _showTagSelector,
                            icon: Icon(Icons.add, size: 18),
                            label: Text("Add Tags"),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (_selectedTags.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _selectedTags.map((tag) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryButtonColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryButtonColor
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tag,
                                      style: TextStyle(
                                        color: AppColors.primaryButtonColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _removeTag(tag),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.primaryButtonColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.label_outline,
                                  color: Colors.grey.shade400,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "No tags selected",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Tap 'Add Tags' to categorize your entry",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 20),

                      // Description Field
                      BlockTalkText(
                        text: "Description",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        onTapOutside: (event) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        decoration: InputDecoration(
                          labelText: 'What did you find? Provide details...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                      ),
                      SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: BlockTalkButton(
                          text: "Submit Entry",
                          type: "solid",
                          buttonColor: AppColors.primaryButtonColor,
                          onPressed: () {
                            _submitEntry();
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Navbar(selectedIndex: 2),
          ],
        ),
      ),
    );
  }
}
