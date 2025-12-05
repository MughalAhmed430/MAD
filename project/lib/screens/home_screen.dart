import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'add_event_screen.dart';
import 'event_details_screen.dart';
import 'favorites_screen.dart';
import 'my_events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = ['All', 'Tech', 'Cultural', 'Sports', 'Workshop', 'Seminar'];
  String selectedCategory = 'All';
  String searchQuery = '';
  int _currentIndex = 0;

  List<Widget> get _screens => [
    _HomeContent(),
    const FavoritesScreen(),
    const AddEventScreen(),
    const MyEventsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF11172A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home_rounded, "Home", 0),
            _buildBottomNavItem(Icons.favorite_rounded, "Favorites", 1),
            _buildBottomNavItem(Icons.add_circle_rounded, "Add", 2),
            _buildBottomNavItem(Icons.event_rounded, "My Events", 3),
            _buildBottomNavItem(Icons.person_rounded, "Profile", 4),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Test button to add featured event
          FloatingActionButton(
            onPressed: () async {
              print('🟡 TEST: Checking events data');
              final eventService = Provider.of<EventService>(context, listen: false);
              final snapshot = await eventService.getEvents().first;

              print('🟡 Total events: ${snapshot.length}');
              print('🟡 Featured events:');
              for (var event in snapshot) {
                print('  - ${event.title}: featured=${event.isFeatured}');
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Found ${snapshot.length} total events'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            backgroundColor: Colors.blue,
            mini: true,
            child: const Icon(Icons.info, size: 20),
          ),
          const SizedBox(height: 10),
          // Main Add Button
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _currentIndex = 2;
              });
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: isActive
                  ? BoxDecoration(
                color: const Color(0xFF00FF9C).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              )
                  : null,
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF00FF9C) : Colors.white.withOpacity(0.7),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF00FF9C) : Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _HomeContent() {
    return _HomeScreenContent(
      selectedCategory: selectedCategory,
      searchQuery: searchQuery,
      categories: categories,
      onCategoryChanged: (category) {
        setState(() {
          selectedCategory = category;
        });
      },
      onSearchChanged: (query) {
        setState(() {
          searchQuery = query;
        });
      },
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  final String selectedCategory;
  final String searchQuery;
  final List<String> categories;
  final Function(String) onCategoryChanged;
  final Function(String) onSearchChanged;

  const _HomeScreenContent({
    required this.selectedCategory,
    required this.searchQuery,
    required this.categories,
    required this.onCategoryChanged,
    required this.onSearchChanged,
  });

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context),
          const SizedBox(height: 20),
          _buildCategoryChips(),
          const SizedBox(height: 25),
          _buildFeaturedEventsSection(context),
          const SizedBox(height: 25),
          _buildUpcomingEventsSection(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF11172A),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF9C).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StreamBuilder<UserModel?>(
                    stream: authService.currentUserData,
                    builder: (context, snapshot) {
                      final userName = snapshot.hasData ? snapshot.data!.name : 'User';
                      return Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: StreamBuilder<UserModel?>(
                  stream: authService.currentUserData,
                  builder: (context, snapshot) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00FF9C),
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF11172A),
                        child: snapshot.hasData && snapshot.data!.profileImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            snapshot.data!.profileImage!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Text(
                          snapshot.hasData ? snapshot.data!.initials : 'U',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FF9C),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white.withOpacity(0.7), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged('');
                    },
                    icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7), size: 20),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = widget.selectedCategory == category;
          return Container(
            margin: EdgeInsets.only(right: index == widget.categories.length - 1 ? 20 : 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.onCategoryChanged(category);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00FF9C) : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00FF9C) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedEventsSection(BuildContext context) {
    final eventService = Provider.of<EventService>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Events',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Refresh button
              IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.7), size: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // ACTUAL FIX: Check ALL events and filter for featured ones
        StreamBuilder<List<Event>>(
          stream: eventService.getEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildFeaturedLoading();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildFeaturedEventsPlaceholder('No events found');
            }

            // Filter for featured events
            final featuredEvents = snapshot.data!.where((event) => event.isFeatured).toList();

            print('🟡 Found ${featuredEvents.length} featured events out of ${snapshot.data!.length} total');

            if (featuredEvents.isEmpty) {
              return _buildFeaturedEventsPlaceholder('No featured events yet');
            }

            // Show featured events in horizontal list
            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: featuredEvents.length,
                itemBuilder: (context, index) {
                  final event = featuredEvents[index];
                  return _buildFeaturedEventCard(event);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedEventCard(Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              event: event,
              eventId: event.id,
            ),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00D1FF).withOpacity(0.8),
              const Color(0xFF00FF9C).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image if available
            if (event.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  event.imageUrl,
                  width: 280,
                  height: 220,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.5),
                  colorBlendMode: BlendMode.darken,
                ),
              ),

            // Content
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent.withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      event.category.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            event.formattedDate,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Icon(Icons.location_on, size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.venue,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

  Widget _buildFeaturedLoading() {
    return SizedBox(
      height: 220,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.05),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FF9C)),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedEventsPlaceholder(String message) {
    return GestureDetector(
      onTap: () {
        // Tap to create featured event
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEventScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF11172A),
              const Color(0xFF1A2238),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_border,
                size: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 15),
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to create featured event',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Events',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onCategoryChanged('All');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF9C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00FF9C).withOpacity(0.3)),
                  ),
                  child: Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF00FF9C),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildUpcomingEventsContent(context),
      ],
    );
  }

  Widget _buildUpcomingEventsContent(BuildContext context) {
    final eventService = Provider.of<EventService>(context);
    final auth = FirebaseAuth.instance;

    return StreamBuilder<List<Event>>(
      stream: eventService.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(color: Color(0xFF00FF9C)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildNoEventsFound();
        }

        final events = _filterEvents(snapshot.data!);

        if (events.isEmpty) {
          return _buildNoMatchingEvents();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Column(
              children: [
                _buildEventCard(context, event, eventService, auth),
                if (index < events.length - 1) const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNoEventsFound() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 60,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 15),
          Text(
            'No Events Found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create the first event in your community!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatchingEvents() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 15),
          Text(
            'No Matching Events',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Try a different search or category',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event, EventService eventService, FirebaseAuth auth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              event: event,
              eventId: event.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: _getCategoryColor(event.category).withOpacity(0.2),
                image: event.imageUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(event.imageUrl),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: event.imageUrl.isEmpty
                  ? Center(
                child: Icon(
                  Icons.event,
                  size: 40,
                  color: _getCategoryColor(event.category),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(event.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          event.category,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getCategoryColor(event.category),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (event.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Featured',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 10),
                      StreamBuilder<bool>(
                        stream: Stream.fromFuture(eventService.isFavorite(event.id, auth.currentUser?.uid ?? '')),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          return GestureDetector(
                            onTap: () async {
                              if (auth.currentUser == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please login to add favorites'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              try {
                                await eventService.toggleFavorite(event.id, auth.currentUser!.uid);
                                setState(() {});
                              } catch (e) {
                                print('🔴 Error toggling favorite: $e');
                              }
                            },
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white70,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white60,
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
      ),
    );
  }

  List<Event> _filterEvents(List<Event> events) {
    List<Event> filtered = List.from(events);

    if (widget.selectedCategory != 'All') {
      filtered = filtered.where((event) => event.category == widget.selectedCategory).toList();
    }

    if (widget.searchQuery.isNotEmpty) {
      filtered = filtered.where((event) =>
      event.title.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
          event.venue.toLowerCase().contains(widget.searchQuery.toLowerCase())
      ).toList();
    }

    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tech':
        return const Color(0xFF00D1FF);
      case 'cultural':
        return const Color(0xFF00FF9C);
      case 'sports':
        return Colors.orange;
      case 'workshop':
        return Colors.purpleAccent;
      case 'seminar':
        return Colors.pinkAccent;
      default:
        return const Color(0xFF00D1FF);
    }
  }
}