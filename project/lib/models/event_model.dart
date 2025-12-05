import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String title;
  String description;
  String venue;
  DateTime date;
  DateTime time;
  String organizer;
  List<String> attendees;
  String imageUrl;
  String category;
  bool isFeatured;
  double rating;
  int maxParticipants;
  bool isFree;
  double price;
  String? requirements;
  List<String> registeredUsers;
  List<String> favoritedBy;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.date,
    required this.time,
    required this.organizer,
    this.attendees = const [],
    this.imageUrl = '',
    this.category = 'General',
    this.isFeatured = false,
    this.rating = 0.0,
    this.maxParticipants = 0,
    this.isFree = true,
    this.price = 0.0,
    this.requirements,
    this.registeredUsers = const [],
    this.favoritedBy = const [],
  });

  // Get combined DateTime
  DateTime get dateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'venue': venue,
      'date': Timestamp.fromDate(date),
      'time': Timestamp.fromDate(time),
      'organizer': organizer,
      'attendees': attendees,
      'imageUrl': imageUrl,
      'category': category,
      'isFeatured': isFeatured,
      'rating': rating,
      'maxParticipants': maxParticipants,
      'isFree': isFree,
      'price': price,
      'requirements': requirements,
      'registeredUsers': registeredUsers,
      'favoritedBy': favoritedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create Event from Firestore document
  factory Event.fromMap(String id, Map<String, dynamic> map) {
    // Debug print to check what fields we're receiving
    print('Parsing event from map - ID: $id');
    print('Map keys: ${map.keys.toList()}');

    try {
      // Handle date - could be Timestamp or could be something else
      DateTime parsedDate;
      if (map['date'] is Timestamp) {
        parsedDate = (map['date'] as Timestamp).toDate();
      } else if (map['date'] is String) {
        parsedDate = DateTime.parse(map['date'] as String);
      } else if (map['date'] is DateTime) {
        parsedDate = map['date'] as DateTime;
      } else {
        print('Warning: date field is unexpected type: ${map['date']?.runtimeType}');
        parsedDate = DateTime.now();
      }

      // Handle time - could be Timestamp or could be something else
      DateTime parsedTime;
      if (map['time'] is Timestamp) {
        parsedTime = (map['time'] as Timestamp).toDate();
      } else if (map['time'] is String) {
        parsedTime = DateTime.parse(map['time'] as String);
      } else if (map['time'] is DateTime) {
        parsedTime = map['time'] as DateTime;
      } else {
        print('Warning: time field is unexpected type: ${map['time']?.runtimeType}');
        parsedTime = DateTime.now();
      }

      return Event(
        id: id,
        title: map['title']?.toString() ?? 'No Title',
        description: map['description']?.toString() ?? 'No Description',
        venue: map['venue']?.toString() ?? 'Unknown Venue',
        date: parsedDate,
        time: parsedTime,
        organizer: map['organizer']?.toString() ?? 'Unknown Organizer',
        attendees: List<String>.from(map['attendees'] ?? []),
        imageUrl: map['imageUrl']?.toString() ?? '',
        category: map['category']?.toString() ?? 'General',
        isFeatured: map['isFeatured'] == true,
        rating: (map['rating'] ?? 0.0).toDouble(),
        maxParticipants: (map['maxParticipants'] ?? 0).toInt(),
        isFree: map['isFree'] != false,
        price: (map['price'] ?? 0.0).toDouble(),
        requirements: map['requirements']?.toString(),
        registeredUsers: List<String>.from(map['registeredUsers'] ?? []),
        favoritedBy: List<String>.from(map['favoritedBy'] ?? []),
      );
    } catch (e) {
      print('Error parsing event from map: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  // Format date for display
  String get formattedDate {
    try {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Format time for display
  String get formattedTime {
    try {
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
      return '$displayHour:$minute $period';
    } catch (e) {
      return 'Invalid Time';
    }
  }

  // Combined date and time
  String get formattedDateTime {
    return '$formattedDate • $formattedTime';
  }

  // Check if event is upcoming
  bool get isUpcoming {
    try {
      return dateTime.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Helper methods for EventDetailsScreen:
  bool isUserRegistered(String userId) {
    return registeredUsers.contains(userId);
  }

  bool isUserFavorite(String userId) {
    return favoritedBy.contains(userId);
  }

  String get remainingSpots {
    if (maxParticipants == 0) return 'Unlimited';
    final remaining = maxParticipants - registeredUsers.length;
    return remaining > 0 ? '$remaining spots left' : 'FULL';
  }

  // Get attendance percentage
  double get attendancePercentage {
    if (maxParticipants == 0) return 0.0;
    return (registeredUsers.length / maxParticipants) * 100;
  }

  // Get formatted price
  String get formattedPrice {
    return isFree ? 'Free' : '\$${price.toStringAsFixed(2)}';
  }

  // Debug method
  void printDebugInfo() {
    print('=== EVENT DEBUG INFO ===');
    print('ID: $id');
    print('Title: $title');
    print('Date: $date (${date.runtimeType})');
    print('Time: $time (${time.runtimeType})');
    print('DateTime: $dateTime');
    print('Category: $category');
    print('Organizer: $organizer');
    print('Venue: $venue');
    print('Image URL: $imageUrl');
    print('Is Featured: $isFeatured');
    print('Is Free: $isFree');
    print('Max Participants: $maxParticipants');
    print('Registered Users: ${registeredUsers.length}');
    print('Favorited By: ${favoritedBy.length}');
    print('Formatted Date: $formattedDate');
    print('Formatted Time: $formattedTime');
    print('Is Upcoming: $isUpcoming');
    print('=======================');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Event &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}