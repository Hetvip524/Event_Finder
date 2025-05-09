import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PredictHQService {
  static const String _baseUrl = 'https://api.predicthq.com/v1/events/';
  static const String _token = 'YOUR_PREDICTHQ_TOKEN'; // Replace with your actual token

  String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'concerts':
        return '🎵';
      case 'sports':
        return '⚽';
      case 'conferences':
        return '🎤';
      case 'expos':
        return '🎪';
      case 'festivals':
        return '🎉';
      case 'performing-arts':
        return '🎭';
      default:
        return '🎟️';
    }
  }

  Future<List<Map<String, dynamic>>> getEvents({
    required LatLng location,
    required double radius,
    String? category,
  }) async {
    try {
      final queryParams = {
        'location_around.origin': '${location.latitude},${location.longitude}',
        'location_around.offset': '${radius}km',
        'sort': '-rank',
        'limit': '50',
        if (category != null) 'category': category,
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }
} 