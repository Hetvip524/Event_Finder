import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Event.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  Set<String> _selectedCategories = {};
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedTimeRange = 'All Day';
  String _searchQuery = '';
  List<Event> _favoriteEvents = [];
  bool _isLoading = false;
  String? _error;

  final EventService _eventService = EventService();

  // Getters
  List<Event> get allEvents => _allEvents;
  List<Event> get filteredEvents => _filteredEvents;
  Set<String> get selectedCategories => _selectedCategories;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get selectedTimeRange => _selectedTimeRange;
  String get searchQuery => _searchQuery;
  List<Event> get favoriteEvents => _favoriteEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with API data
  EventProvider() {
    _loadEvents();
    _loadFavorites();
  }

  Future<void> _loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allEvents = await _eventService.fetchEvents();
      _filteredEvents = _allEvents;
      if (_allEvents.isEmpty) {
        _error = 'No events found in your area. Try adjusting your filters.';
      }
    } catch (e) {
      _error = 'Failed to load events: ${e.toString()}';
      print('Error loading events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search functionality
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _filteredEvents = _allEvents;
      } else {
        _filteredEvents = await _eventService.searchEvents(query);
        if (_filteredEvents.isEmpty) {
          _error = 'No events found matching your search.';
        }
      }
    } catch (e) {
      _error = 'Failed to search events: ${e.toString()}';
      print('Error searching events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Category management
  Future<void> toggleCategory(String category) async {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    await _applyFilters();
  }

  // Date range management
  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    _startDate = start;
    _endDate = end;
    await _applyFilters();
  }

  // Time range management
  Future<void> setTimeRange(String range) async {
    _selectedTimeRange = range;
    await _applyFilters();
  }

  // Apply all filters
  Future<void> _applyFilters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _filteredEvents = await _eventService.filterEvents(
        category: _selectedCategories.isNotEmpty ? _selectedCategories.first : null,
        startDate: _startDate,
        endDate: _endDate,
        timeRange: _selectedTimeRange != 'All Day' ? _selectedTimeRange : null,
      );
      if (_filteredEvents.isEmpty) {
        _error = 'No events found matching your filters.';
      }
    } catch (e) {
      _error = 'Failed to filter events: ${e.toString()}';
      print('Error filtering events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Favorites management
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteEventIds = prefs.getStringList('favoriteEvents');
    if (favoriteEventIds != null) {
      _favoriteEvents = favoriteEventIds.map((id) {
        final parts = id.split('|');
        return Event(
          parts[0], // title
          parts[1], // location
          parts[2], // date
          category: parts[3], // category
          time: parts[4], // time
          address: parts[5], // address
          description: parts[6], // description
          imageUrl: parts.length > 7 ? parts[7] : null, // imageUrl
        );
      }).toList();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteEventIds = prefs.getStringList('favoriteEvents') ?? [];
    
    final eventId = '${event.title}|${event.location}|${event.date}|${event.category}|${event.time}|${event.address}|${event.description}|${event.imageUrl}';
    
    if (favoriteEventIds.contains(eventId)) {
      favoriteEventIds.remove(eventId);
      _favoriteEvents.removeWhere((e) => e.title == event.title);
    } else {
      favoriteEventIds.add(eventId);
      _favoriteEvents.add(event);
    }
    
    await prefs.setStringList('favoriteEvents', favoriteEventIds);
    notifyListeners();
  }

  bool isFavorite(Event event) {
    return _favoriteEvents.any((e) => e.title == event.title);
  }
} 