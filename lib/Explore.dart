import 'package:flutter/material.dart';
import './Event.dart';
import './Detail.dart';
import './Favorites.dart';
import './MapScreen.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  Set<String> selectedCategories = {};
  DateTime? startDate;
  DateTime? endDate;
  String selectedTimeRange = 'All Day';
  final List<String> timeRanges = ['All Day', 'Morning (6AM-12PM)', 'Afternoon (12PM-5PM)', 'Evening (5PM-12AM)'];

  // Sample events data with categories
  final List<Event> allEvents = [
    Event(
      "Music Festival",
      "Central Park",
      "2024-03-20",
      category: EventCategories.music,
      time: "7:00 PM",
      address: "Central Park, New York, NY 10024",
      description: "Join us for an amazing night of live music featuring top artists from around the world. Food and drinks available.",
    ),
    Event(
      "Art Exhibition",
      "City Gallery",
      "2024-03-25",
      category: EventCategories.art,
      time: "10:00 AM",
      address: "123 Gallery Street, New York, NY 10001",
      description: "Experience contemporary art from emerging artists. Special guided tours available.",
    ),
    Event(
      "Food Festival",
      "Downtown Square",
      "2024-03-30",
      category: EventCategories.food,
      time: "11:00 AM",
      address: "Downtown Square, New York, NY 10013",
      description: "Taste cuisines from around the world. Over 50 food vendors, live cooking demonstrations, and more!",
    ),
    Event(
      "Tech Conference",
      "Convention Center",
      "2024-04-05",
      category: EventCategories.tech,
      time: "9:00 AM",
      address: "655 W 34th St, New York, NY 10001",
      description: "Learn about the latest technologies and network with industry leaders. Workshops and panel discussions included.",
    ),
    Event(
      "Dance Workshop",
      "Dance Studio",
      "2024-04-10",
      category: EventCategories.art,
      time: "6:00 PM",
      address: "500 Dance Ave, New York, NY 10011",
      description: "Learn various dance styles from professional instructors. All skill levels welcome.",
    ),
    Event(
      "Startup Meetup",
      "Innovation Hub",
      "2024-04-15",
      category: EventCategories.tech,
      time: "7:30 PM",
      address: "350 Tech Street, New York, NY 10012",
      description: "Connect with fellow entrepreneurs and investors. Pitch your ideas and get valuable feedback.",
    ),
    Event(
      "Street Food Fair",
      "City Center",
      "2024-04-20",
      category: EventCategories.food,
      time: "12:00 PM",
      address: "City Center Plaza, New York, NY 10019",
      description: "Experience the best street food vendors in the city. Live music and entertainment throughout the day.",
    ),
    Event(
      "Jazz Night",
      "Blue Note Club",
      "2024-04-25",
      category: EventCategories.music,
      time: "8:00 PM",
      address: "131 W 3rd St, New York, NY 10012",
      description: "Enjoy an evening of smooth jazz with renowned musicians. Dinner and drinks available.",
    ),
    Event(
      "Sports Tournament",
      "City Stadium",
      "2024-05-01",
      category: EventCategories.sports,
      time: "2:00 PM",
      address: "City Stadium, New York, NY 10001",
      description: "Watch teams compete in various sports. Food vendors and entertainment available throughout the event.",
    ),
  ];

  List<Event> get filteredEvents {
    List<Event> filtered = allEvents;

    // Apply category filter
    if (selectedCategories.isNotEmpty) {
      filtered = filtered.where((event) => selectedCategories.contains(event.category)).toList();
    }

    // Apply date range filter
    if (startDate != null && endDate != null) {
      filtered = filtered.where((event) {
        final eventDate = DateFormat('yyyy-MM-dd').parse(event.date);
        return eventDate.isAfter(startDate!.subtract(Duration(days: 1))) && 
               eventDate.isBefore(endDate!.add(Duration(days: 1)));
      }).toList();
    }

    // Apply time range filter
    if (selectedTimeRange != 'All Day') {
      filtered = filtered.where((event) {
        if (event.time.isEmpty) return false;
        
        final time = event.time.split(' ')[0];
        final hour = int.parse(time.split(':')[0]);
        final isPM = event.time.contains('PM');

        switch (selectedTimeRange) {
          case 'Morning (6AM-12PM)':
            return !isPM && hour >= 6;
          case 'Afternoon (12PM-5PM)':
            return (isPM && hour < 5) || (!isPM && hour == 12);
          case 'Evening (5PM-12AM)':
            return (isPM && hour >= 5) || (!isPM && hour == 12);
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? DateTime.now() : (endDate ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025, 12, 31),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _handleAdd(context, Event toAdd) {
    // TODO: Implement favorites functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${toAdd.title} added to favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Events',
                    style: AppTheme.heading1.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find events by category or location',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list, color: AppTheme.primaryColor),
                      onPressed: () {
                        // Show filter dialog
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Events Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Events',
                    style: AppTheme.heading2,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return _buildEventCard(
                        event.title,
                        event.location,
                        'lib/images/dance.jpg',
                      );
                    },
                  ),
                    ],
              ),
            ),
          ],
        ),
              ),
            );
          }

  Widget _buildEventCard(String title, String location, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: AppTheme.subtitleColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.subtitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
