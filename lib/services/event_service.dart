import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../Event.dart';
import 'package:intl/intl.dart';

class EventService {
  static const String _baseUrl = 'https://api.predicthq.com/v1/events/';
  static const String _apiKey = 'HAdymEDZ0SJTAJng2Saz3d1sR8MugPPp8otevVxX';

  Future<List<Event>> fetchEvents() async {
    try {
      // Default to New York City coordinates if location is not available
      final LatLng defaultLocation = LatLng(40.7128, -74.0060);
      
      final queryParams = {
        'location_around.origin': '${defaultLocation.latitude},${defaultLocation.longitude}',
        'location_around.radius': '20km',
        'sort': 'rank',
        'limit': '100',
        'active.gte': DateTime.now().toIso8601String(),
        'active.lte': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      };

      print('Fetching events with params: $queryParams');

      final response = await http.get(
        Uri.parse(_baseUrl).replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      print('API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        print('Number of events found: ${results.length}');
        
        List<Event> events = results.map((json) {
          final location = json['location'] != null && json['location'] is List && json['location'].isNotEmpty
              ? json['location'][0].toString()
              : json['country'] ?? 'Unknown Location';

          final startDate = json['start'] != null 
              ? DateTime.parse(json['start']).toLocal()
              : DateTime.now();

          return Event(
            json['title'] ?? 'Untitled Event',
            location,
            DateFormat('yyyy-MM-dd').format(startDate),
            category: json['category'] ?? 'Other',
            time: DateFormat('HH:mm').format(startDate),
            address: json['address'] ?? 'Address not specified',
            description: json['description'] ?? 'No description available',
            imageUrl: json['entities']?[0]?['images']?[0]?['url'],
          );
        }).toList();

        // If no events found from API, return sample events
        if (events.isEmpty) {
          return _getSampleEvents();
        }

        return events;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        // Return sample events on API error
        return _getSampleEvents();
      }
    } catch (e, stackTrace) {
      print('Error fetching events: $e');
      print('Stack trace: $stackTrace');
      // Return sample events on error
      return _getSampleEvents();
    }
  }

  // Helper method to get sample events
  List<Event> _getSampleEvents() {
    final now = DateTime.now();
    return [
      Event(
        'Tech Innovation Summit 2024',
        'Convention Center',
        DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 7))),
        category: 'Tech',
        time: '09:00',
        address: '123 Innovation Drive, New York, NY 10001',
        description: 'Join industry leaders for a day of cutting-edge technology discussions and networking opportunities.',
        imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87',
      ),
      Event(
        'Summer Music Festival',
        'Central Park',
        DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 14))),
        category: 'Music',
        time: '14:00',
        address: 'Central Park, New York, NY 10024',
        description: 'A day of live music performances featuring local and international artists.',
        imageUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea',
      ),
      Event(
        'Food & Wine Expo',
        'Grand Hotel',
        DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 3))),
        category: 'Food',
        time: '18:30',
        address: '456 Gourmet Avenue, New York, NY 10013',
        description: 'Experience culinary delights from top chefs and wine experts.',
        imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
      ),
      Event(
        'Modern Art Exhibition',
        'City Gallery',
        DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 5))),
        category: 'Art',
        time: '10:00',
        address: '789 Gallery Row, New York, NY 10011',
        description: 'Contemporary art showcase featuring emerging and established artists.',
        imageUrl: 'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e',
      ),
      Event(
        'Startup Networking Night',
        'Innovation Hub',
        DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 10))),
        category: 'Tech',
        time: '19:00',
        address: '321 Startup Lane, New York, NY 10016',
        description: 'Connect with fellow entrepreneurs and investors in a casual setting.',
        imageUrl: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b',
      ),
      Event(
        'Jazz in the Park',
        'Washington Square Park',
        DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 2))),
        category: 'Music',
        time: '16:00',
        address: 'Washington Square Park, New York, NY 10012',
        description: 'Free outdoor jazz concert featuring local musicians.',
        imageUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629',
      ),
    ];
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      final LatLng defaultLocation = LatLng(40.7128, -74.0060);
      
      final queryParams = {
        'location_around.origin': '${defaultLocation.latitude},${defaultLocation.longitude}',
        'location_around.radius': '20km',
        'sort': 'rank',
        'limit': '100',
        'q': query,
        'active.gte': DateTime.now().toIso8601String(),
        'active.lte': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      };

      print('Searching events with params: $queryParams');

      final response = await http.get(
        Uri.parse(_baseUrl).replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      print('Search API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        print('Number of search results: ${results.length}');

        List<Event> events = results.map((json) {
          final location = json['location'] != null && json['location'] is List && json['location'].isNotEmpty
              ? json['location'][0].toString()
              : json['country'] ?? 'Unknown Location';

          final startDate = json['start'] != null 
              ? DateTime.parse(json['start']).toLocal()
              : DateTime.now();

          return Event(
            json['title'] ?? 'Untitled Event',
            location,
            DateFormat('yyyy-MM-dd').format(startDate),
            category: json['category'] ?? 'Other',
            time: DateFormat('HH:mm').format(startDate),
            address: json['address'] ?? 'Address not specified',
            description: json['description'] ?? 'No description available',
            imageUrl: json['entities']?[0]?['images']?[0]?['url'],
          );
        }).toList();

        // If no events found from API, filter sample events
        if (events.isEmpty) {
          return _getSampleEvents().where((event) =>
            event.title.toLowerCase().contains(query.toLowerCase()) ||
            event.description.toLowerCase().contains(query.toLowerCase()) ||
            event.category.toLowerCase().contains(query.toLowerCase())
          ).toList();
        }

        return events;
      } else {
        print('Search API Error: ${response.statusCode} - ${response.body}');
        // Return filtered sample events on API error
        return _getSampleEvents().where((event) =>
          event.title.toLowerCase().contains(query.toLowerCase()) ||
          event.description.toLowerCase().contains(query.toLowerCase()) ||
          event.category.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    } catch (e, stackTrace) {
      print('Error searching events: $e');
      print('Stack trace: $stackTrace');
      // Return filtered sample events on error
      return _getSampleEvents().where((event) =>
        event.title.toLowerCase().contains(query.toLowerCase()) ||
        event.description.toLowerCase().contains(query.toLowerCase()) ||
        event.category.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }

  Future<List<Event>> filterEvents({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? timeRange,
  }) async {
    try {
      final LatLng defaultLocation = LatLng(40.7128, -74.0060);
      
      final queryParams = {
        'location_around.origin': '${defaultLocation.latitude},${defaultLocation.longitude}',
        'location_around.radius': '20km',
        'sort': 'rank',
        'limit': '100',
        'active.gte': (startDate ?? DateTime.now()).toIso8601String(),
        'active.lte': (endDate ?? DateTime.now().add(Duration(days: 30))).toIso8601String(),
      };

      if (category != null) {
        queryParams['category'] = category.toLowerCase();
      }

      print('Filtering events with params: $queryParams');

      final response = await http.get(
        Uri.parse(_baseUrl).replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      print('Filter API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        print('Number of filtered results: ${results.length}');

        List<Event> events = results.map((json) {
          final location = json['location'] != null && json['location'] is List && json['location'].isNotEmpty
              ? json['location'][0].toString()
              : json['country'] ?? 'Unknown Location';

          final eventStartDate = json['start'] != null 
              ? DateTime.parse(json['start']).toLocal()
              : DateTime.now();

          return Event(
            json['title'] ?? 'Untitled Event',
            location,
            DateFormat('yyyy-MM-dd').format(eventStartDate),
            category: json['category'] ?? 'Other',
            time: DateFormat('HH:mm').format(eventStartDate),
            address: json['address'] ?? 'Address not specified',
            description: json['description'] ?? 'No description available',
            imageUrl: json['entities']?[0]?['images']?[0]?['url'],
          );
        }).toList();

        // If no events found from API, filter sample events
        if (events.isEmpty) {
          return _filterSampleEvents(category: category, startDate: startDate, endDate: endDate, timeRange: timeRange);
        }

        return events;
      } else {
        print('Filter API Error: ${response.statusCode} - ${response.body}');
        // Return filtered sample events on API error
        return _filterSampleEvents(category: category, startDate: startDate, endDate: endDate, timeRange: timeRange);
      }
    } catch (e, stackTrace) {
      print('Error filtering events: $e');
      print('Stack trace: $stackTrace');
      // Return filtered sample events on error
      return _filterSampleEvents(category: category, startDate: startDate, endDate: endDate, timeRange: timeRange);
    }
  }

  List<Event> _filterSampleEvents({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? timeRange,
  }) {
    List<Event> events = _getSampleEvents();

    if (category != null) {
      events = events.where((event) => 
        event.category.toLowerCase() == category.toLowerCase()
      ).toList();
    }

    if (startDate != null) {
      events = events.where((event) {
        final eventDate = DateFormat('yyyy-MM-dd').parse(event.date);
        return eventDate.isAfter(startDate.subtract(Duration(days: 1)));
      }).toList();
    }

    if (endDate != null) {
      events = events.where((event) {
        final eventDate = DateFormat('yyyy-MM-dd').parse(event.date);
        return eventDate.isBefore(endDate.add(Duration(days: 1)));
      }).toList();
    }

    if (timeRange != null && timeRange != 'All Day') {
      events = events.where((event) {
        final time = int.parse(event.time.split(':')[0]);
        switch (timeRange) {
          case 'Morning (6AM-12PM)':
            return time >= 6 && time < 12;
          case 'Afternoon (12PM-5PM)':
            return time >= 12 && time < 17;
          case 'Evening (5PM-12AM)':
            return time >= 17 || time < 6;
          default:
            return true;
        }
      }).toList();
    }

    return events;
  }
} 