import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  final String eventId;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.eventId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isLoading = false;
  bool _isRegistered = false;
  bool _isFavorite = false;
  int _registeredCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final eventService = Provider.of<EventService>(context, listen: false);

      // Check registration status
      _isRegistered = await eventService.isUserRegistered(widget.eventId, currentUser.uid);

      // Check favorite status
      _isFavorite = await eventService.isFavorite(widget.eventId, currentUser.uid);

      // Get registration count
      _registeredCount = await eventService.getRegistrationCount(widget.eventId);

      print('Loaded data - Registered: $_isRegistered, Favorite: $_isFavorite, Count: $_registeredCount');
    } catch (e) {
      print('Error loading event data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleRegistration() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to register for events'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventService = Provider.of<EventService>(context, listen: false);

      if (_isRegistered) {
        // Unregister
        await eventService.cancelRegistration(widget.eventId, currentUser.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully unregistered from event'),
            backgroundColor: Color(0xFF00FF9C),
          ),
        );
        setState(() {
          _isRegistered = false;
          _registeredCount = _registeredCount > 0 ? _registeredCount - 1 : 0;
        });
      } else {
        // Register
        await eventService.registerForEvent(widget.eventId, currentUser.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for event!'),
            backgroundColor: Color(0xFF00FF9C),
          ),
        );
        setState(() {
          _isRegistered = true;
          _registeredCount++;
        });
      }

      print('Registration toggled - Now registered: $_isRegistered');
    } catch (e) {
      print('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to save favorites'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventService = Provider.of<EventService>(context, listen: false);

      // Store the current state before toggling
      final wasFavorite = _isFavorite;

      // Call the service to toggle favorite
      await eventService.toggleFavorite(widget.eventId, currentUser.uid);

      // Update local state to the opposite of what it was
      setState(() {
        _isFavorite = !wasFavorite;
      });

      // Show appropriate message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!wasFavorite ? 'Added to favorites!' : 'Removed from favorites'),
          backgroundColor: !wasFavorite ? const Color(0xFF00FF9C) : Colors.blue,
        ),
      );

      print('Favorite toggled - Was: $wasFavorite, Now: $_isFavorite');
    } catch (e) {
      print('Favorite error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tech':
      case 'technology':
        return const Color(0xFF00D1FF);
      case 'cultural':
        return const Color(0xFF00FF9C);
      case 'sports':
        return Colors.orange;
      case 'workshop':
      case 'career':
        return Colors.purpleAccent;
      case 'seminar':
      case 'business':
        return Colors.pinkAccent;
      default:
        return const Color(0xFF00D1FF);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tech':
      case 'technology':
        return Icons.computer;
      case 'cultural':
        return Icons.music_note;
      case 'business':
        return Icons.business;
      case 'sports':
        return Icons.sports_soccer;
      case 'career':
        return Icons.work;
      case 'workshop':
        return Icons.build;
      case 'seminar':
        return Icons.school;
      default:
        return Icons.event;
    }
  }

  String _formatDateTime() {
    final date = widget.event.date;
    final time = widget.event.time;

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final day = days[date.weekday - 1];
    final month = months[date.month - 1];

    String hour = time.hour.toString();
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.hour < 12 ? 'AM' : 'PM';

    if (time.hour > 12) hour = (time.hour - 12).toString();
    if (time.hour == 0) hour = '12';

    return '$day, $month ${date.day}, ${date.year} • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                    ),
                    onPressed: _isLoading ? null : _toggleFavorite,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCategoryColor(widget.event.category).withOpacity(0.8),
                          _getCategoryColor(widget.event.category).withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(widget.event.category),
                        size: 100,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title
                      Text(
                        widget.event.title,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.event.category).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getCategoryColor(widget.event.category).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          widget.event.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: _getCategoryColor(widget.event.category),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Organizer
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Organized by: ${widget.event.organizer}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats Row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              Icons.people,
                              'Participants',
                              '$_registeredCount',
                            ),
                            _buildStatItem(
                              Icons.event_available,
                              'Status',
                              widget.event.isUpcoming ? 'Upcoming' : 'Past',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Details Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.location_on,
                              title: 'Venue',
                              value: widget.event.venue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.calendar_today,
                              title: 'Date & Time',
                              value: _formatDateTime(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Description
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.event.description,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isLoading ? null : _toggleRegistration,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: _isRegistered
                                      ? Colors.red.withOpacity(0.15)
                                      : const Color(0xFF00D1FF).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _isRegistered ? Colors.red : const Color(0xFF00D1FF),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _isRegistered ? 'UNREGISTER' : 'REGISTER NOW',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _isRegistered ? Colors.red : const Color(0xFF00D1FF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isLoading ? null : _toggleFavorite,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: _isFavorite
                                      ? Colors.red.withOpacity(0.15)
                                      : const Color(0xFF00FF9C).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _isFavorite ? Colors.red : const Color(0xFF00FF9C),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: _isFavorite ? Colors.red : const Color(0xFF00FF9C),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isFavorite ? 'FAVORITED' : 'FAVORITE',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _isFavorite ? Colors.red : const Color(0xFF00FF9C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00FF9C),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D1FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00D1FF), size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF00FF9C),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}