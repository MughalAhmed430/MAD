import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../models/event_model.dart';
import 'package:intl/intl.dart';
import 'add_event_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({Key? key}) : super(key: key);

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  int _selectedTab = 0;

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tech':
        return const Color(0xFF00D1FF);
      case 'cultural':
        return Colors.purpleAccent;
      case 'sports':
        return Colors.greenAccent;
      case 'workshop':
        return Colors.orangeAccent;
      case 'seminar':
        return Colors.blueAccent;
      case 'social':
        return Colors.pinkAccent;
      case 'academic':
        return Colors.cyanAccent;
      case 'career':
        return Colors.amberAccent;
      default:
        return const Color(0xFF00FF9C);
    }
  }

  Widget _buildDetailRow(IconData icon, String text, {Color color = Colors.white}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _editEvent(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(eventToEdit: event),
      ),
    );
  }

  void _showEventDetails(BuildContext context, Event event, {bool isCreated = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (event.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          event.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(event.category).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getCategoryColor(event.category),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            event.category,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(event.category),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (event.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.amber,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  'Featured',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(Icons.location_on, event.venue, color: const Color(0xFF00D1FF)),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.calendar_today,
                      '${DateFormat('EEEE, MMMM d, yyyy').format(event.date)} at ${DateFormat('h:mm a').format(event.time)}',
                      color: const Color(0xFF00FF9C),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.attach_money,
                      event.isFree ? 'Free Event' : '\$${event.price.toStringAsFixed(2)}',
                      color: event.isFree ? const Color(0xFF00FF9C) : Colors.amber,
                    ),
                    if (event.maxParticipants > 0) ...[
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        Icons.people,
                        '${event.maxParticipants} spots available',
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      event.description,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    if (event.requirements != null && event.requirements!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Requirements',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        event.requirements!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        if (isCreated)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _editEvent(context, event);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D1FF),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Edit Event',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        if (isCreated) const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              isCreated ? 'Cancel' : 'Close',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'My Events',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Events you\'ve registered for or created',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? const Color(0xFF00FF9C).withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _selectedTab == 0
                                ? Border.all(color: const Color(0xFF00FF9C).withOpacity(0.5))
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Registered',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == 0
                                    ? const Color(0xFF00FF9C)
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? const Color(0xFF00D1FF).withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _selectedTab == 1
                                ? Border.all(color: const Color(0xFF00D1FF).withOpacity(0.5))
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Created',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == 1
                                    ? const Color(0xFF00D1FF)
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _selectedTab == 0
                  ? _buildRegisteredEvents(userId)
                  : _buildCreatedEvents(userId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredEvents(String userId) {
    return StreamBuilder<List<Event>>(
      stream: Provider.of<EventService>(context).getRegisteredEvents(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF00FF9C),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 20),
                Text(
                  'No registered events',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Register for events to see them here',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        final events = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(context, event, isRegistered: true);
          },
        );
      },
    );
  }

  Widget _buildCreatedEvents(String userId) {
    return StreamBuilder<List<Event>>(
      stream: Provider.of<EventService>(context).getEventsByOrganizer(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF00D1FF),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.create,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 20),
                Text(
                  'No created events',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Create your first event to see it here',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEventScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF9C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Create Event',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final events = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(context, event, isCreated: true);
          },
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, Event event, {bool isRegistered = false, bool isCreated = false}) {
    return GestureDetector(
      onTap: () {
        _showEventDetails(context, event, isCreated: isCreated);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isCreated ? const Color(0xFF00D1FF) : const Color(0xFF00FF9C)).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    height: 150,
                    color: Colors.white.withOpacity(0.1),
                    child: event.imageUrl.isNotEmpty
                        ? Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF00FF9C),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                        : Center(
                      child: Icon(
                        Icons.event,
                        size: 60,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                if (isRegistered || isCreated)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isCreated ? const Color(0xFF00D1FF) : const Color(0xFF00FF9C)).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCreated ? 'CREATED' : 'REGISTERED',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(event.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getCategoryColor(event.category).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          event.category,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(event.category),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: const Color(0xFF00D1FF).withOpacity(0.8),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: const Color(0xFF00FF9C).withOpacity(0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d, yyyy').format(event.date),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: const Color(0xFF00FF9C).withOpacity(0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('h:mm a').format(event.time),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: event.isFree
                                ? const Color(0xFF00FF9C).withOpacity(0.8)
                                : Colors.amber.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.isFree ? 'Free' : '\$${event.price.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: event.isFree
                                  ? const Color(0xFF00FF9C)
                                  : Colors.amber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${event.maxParticipants > 0 ? '${event.maxParticipants} spots' : 'Unlimited'}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      if (isCreated)
                        GestureDetector(
                          onTap: () {
                            _editEvent(context, event);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: const Color(0xFF00D1FF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFF00D1FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
}