import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import './services/predict_hq_service.dart';
import 'package:intl/intl.dart';
import './theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _defaultCenter = LatLng(22.6916, 72.8634); // Default to Changa, Gujarat
  final PredictHQService _predictHQService = PredictHQService();
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedCategory;
  double _radius = 20; // km
  final dateFormat = DateFormat('MMM d, yyyy · h:mm a');

  final List<String> _categories = [
    'concerts',
    'sports',
    'conferences',
    'expos',
    'festivals',
    'performing-arts',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Using default location.';
          _currentLocation = _defaultCenter;
        });
        _loadEvents();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied. Using default location.';
            _currentLocation = _defaultCenter;
          });
          _loadEvents();
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _errorMessage = null;
      });
      _loadEvents();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _currentLocation = _defaultCenter;
      });
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _predictHQService.getEvents(
        location: _currentLocation ?? _defaultCenter,
        radius: _radius,
        category: _selectedCategory,
      );

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Event Explorer',
            style: AppTheme.heading2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppTheme.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _getCurrentLocation,
            ),
          ],
        ),
        body: Stack(
          children: [
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : FlutterMap(
                    options: MapOptions(
                      center: _currentLocation ?? _defaultCenter,
                      zoom: 14.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.eventfinder',
                      ),
                      MarkerLayer(
                        markers: [
                          if (_currentLocation != null)
                            Marker(
                              width: 60,
                              height: 60,
                              point: _currentLocation!,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryColor,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ..._events.map((event) {
                            final location = LatLng(
                              event['location'][1].toDouble(),
                              event['location'][0].toDouble(),
                            );
                            return Marker(
                              width: 60,
                              height: 60,
                              point: location,
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => DraggableScrollableSheet(
                                      initialChildSize: 0.6,
                                      minChildSize: 0.3,
                                      maxChildSize: 0.9,
                                      builder: (_, controller) => Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(24),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: SingleChildScrollView(
                                          controller: controller,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor,
                                                  borderRadius: const BorderRadius.vertical(
                                                    top: Radius.circular(24),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.all(12),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Text(
                                                            _predictHQService.getCategoryIcon(event['category']),
                                                            style: const TextStyle(fontSize: 32),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 16),
                                                        Expanded(
                                                          child: Text(
                                                            event['title'],
                                                            style: AppTheme.heading2.copyWith(
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.calendar_today, 
                                                             color: Colors.white.withOpacity(0.9),
                                                             size: 20),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          dateFormat.format(DateTime.parse(event['start'])),
                                                          style: AppTheme.bodyLarge.copyWith(
                                                            color: Colors.white.withOpacity(0.9),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      leading: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: AppTheme.secondaryColor.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Icon(Icons.location_on, 
                                                                  color: AppTheme.secondaryColor),
                                                      ),
                                                      title: Text(
                                                        'Location',
                                                        style: AppTheme.bodyMedium.copyWith(
                                                          color: AppTheme.subtitleColor,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        event['location_name'] ?? 'Location details not available',
                                                        style: AppTheme.bodyLarge.copyWith(
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    if (event['description'] != null) ...[
                                                      const SizedBox(height: 20),
                                                      Text(
                                                        'About',
                                                        style: AppTheme.heading3,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        event['description'],
                                                        style: AppTheme.bodyLarge.copyWith(
                                                          height: 1.5,
                                                          color: AppTheme.textColor.withOpacity(0.8),
                                                        ),
                                                      ),
                                                    ],
                                                    if (event['rank'] != null) ...[
                                                      const SizedBox(height: 20),
                                                      Container(
                                                        padding: const EdgeInsets.all(16),
                                                        decoration: BoxDecoration(
                                                          color: AppTheme.accentColor.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.all(8),
                                                              decoration: BoxDecoration(
                                                                color: AppTheme.accentColor.withOpacity(0.2),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Icon(Icons.star, 
                                                                        color: AppTheme.accentColor),
                                                            ),
                                                            const SizedBox(width: 12),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'Impact Rating',
                                                                  style: AppTheme.bodyMedium.copyWith(
                                                                    color: AppTheme.subtitleColor,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${event['rank'].round()}',
                                                                  style: AppTheme.heading2.copyWith(
                                                                    color: AppTheme.accentColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _predictHQService.getCategoryIcon(event['category']),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
            if (_errorMessage != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: AppTheme.heading3,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCategory,
                            hint: Text(
                              'Select Category',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.subtitleColor,
                              ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  'All Categories',
                                  style: AppTheme.bodyMedium,
                                ),
                              ),
                              ..._categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _predictHQService.getCategoryIcon(category),
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        category.toUpperCase(),
                                        style: AppTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                              _loadEvents();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.radio_button_checked, 
                                     color: AppTheme.primaryColor, 
                                     size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search Radius: ${_radius.round()} km',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppTheme.primaryColor,
                          inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.2),
                          thumbColor: AppTheme.primaryColor,
                          overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                          valueIndicatorColor: AppTheme.primaryColor,
                          valueIndicatorTextStyle: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                        ),
                        child: Slider(
                          value: _radius,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          label: '${_radius.round()} km',
                          onChanged: (value) {
                            setState(() {
                              _radius = value;
                            });
                          },
                          onChangeEnd: (value) {
                            _loadEvents();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 