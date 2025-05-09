import 'package:flutter/material.dart';
import './Event.dart';
import './Detail.dart';
import './MapScreen.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class HomeExplore extends StatefulWidget {
  const HomeExplore({super.key});

  @override
  _HomeExploreState createState() => _HomeExploreState();
}

class _HomeExploreState extends State<HomeExplore> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> timeRanges = ['All Day', 'Morning (6AM-12PM)', 'Afternoon (12PM-5PM)', 'Evening (5PM-12AM)'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<EventProvider>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
        ? context.read<EventProvider>().startDate ?? DateTime.now()
        : context.read<EventProvider>().endDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025, 12, 31),
    );
    if (picked != null) {
      final provider = context.read<EventProvider>();
      if (isStartDate) {
        provider.setDateRange(picked, provider.endDate);
      } else {
        provider.setDateRange(provider.startDate, picked);
      }
    }
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
                    'Discover Events',
                    style: AppTheme.heading1.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find the best events happening around you',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search and Filter Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                children: [
                  // Search Bar
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
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Range Filter
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.calendar_today),
                          label: Text(
                            context.watch<EventProvider>().startDate == null 
                              ? 'Start Date' 
                              : DateFormat('MMM dd').format(context.watch<EventProvider>().startDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () => _selectDate(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.calendar_today),
                          label: Text(
                            context.watch<EventProvider>().endDate == null 
                              ? 'End Date' 
                              : DateFormat('MMM dd').format(context.watch<EventProvider>().endDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () => _selectDate(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Time Range Filter
                  DropdownButtonFormField<String>(
                    value: context.watch<EventProvider>().selectedTimeRange,
                    decoration: InputDecoration(
                      labelText: 'Time Range',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: timeRanges.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<EventProvider>().setTimeRange(newValue);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Categories Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: AppTheme.heading2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryCard('Music', Icons.music_note),
                        _buildCategoryCard('Sports', Icons.sports_soccer),
                        _buildCategoryCard('Art', Icons.palette),
                        _buildCategoryCard('Food', Icons.restaurant),
                        _buildCategoryCard('Tech', Icons.computer),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Events Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Events',
                    style: AppTheme.heading2,
                  ),
                  const SizedBox(height: 16),
                  if (context.watch<EventProvider>().isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (context.watch<EventProvider>().error != null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.watch<EventProvider>().error!,
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else if (context.watch<EventProvider>().filteredEvents.isEmpty)
                    const Center(
                      child: Text(
                        'No events found. Try adjusting your filters.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: context.watch<EventProvider>().filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = context.watch<EventProvider>().filteredEvents[index];
                            return _buildEventCard(
                              event.title,
                              event.location,
                              '',  // Empty string since we're not using local images
                              event,
                            );
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    final isSelected = context.watch<EventProvider>().selectedCategories.contains(title);
    return GestureDetector(
      onTap: () {
        context.read<EventProvider>().toggleCategory(title);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, 
              color: isSelected ? Colors.white : AppTheme.primaryColor, 
              size: 32
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(String title, String location, String defaultImagePath, Event event) {
    // List of fallback images for different categories
    final categoryImages = {
      'Tech': 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?w=800&auto=format&fit=crop',
      'Music': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&auto=format&fit=crop',
      'Food': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop',
      'Art': 'https://images.unsplash.com/photo-1561839561-b13bcfe95249?w=800&auto=format&fit=crop',
      'Sports': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800&auto=format&fit=crop',
      'Other': 'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=800&auto=format&fit=crop',
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Detail(event)),
        );
      },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with gradient overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    child: Image.network(
                      event.imageUrl ?? categoryImages[event.category] ?? categoryImages['Other']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          child: Icon(
                            _getCategoryIcon(event.category),
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(event.category),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Date badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat('MMM d').format(DateFormat('yyyy-MM-dd').parse(event.date)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Event Details Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          context.watch<EventProvider>().isFavorite(event)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: context.watch<EventProvider>().isFavorite(event)
                              ? Colors.red
                              : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => context.read<EventProvider>().toggleFavorite(event),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        event.time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tech':
        return Icons.computer;
      case 'music':
        return Icons.music_note;
      case 'food':
        return Icons.restaurant;
      case 'art':
        return Icons.palette;
      case 'sports':
        return Icons.sports;
      default:
        return Icons.event;
    }
  }
} 