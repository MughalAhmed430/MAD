import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> testFirestoreConnection() async {
    try {
      final testRef = _firestore.collection('test').doc('connection_test');
      await testRef.set({
        'test': 'Hello Firestore',
        'timestamp': FieldValue.serverTimestamp(),
      });
      await testRef.delete();
    } catch (e) {
      throw Exception('Firestore connection failed: $e');
    }
  }

  Future<String?> _uploadImageForWeb({
    Uint8List? bytes,
    XFile? xFile,
  }) async {
    try {
      if (bytes == null && xFile == null) return null;

      Uint8List imageBytes;
      if (bytes != null) {
        imageBytes = bytes;
      } else {
        imageBytes = await xFile!.readAsBytes();
      }

      final fileName = 'event-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('event-images/$fileName');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = ref.putData(imageBytes, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String> createEvent({
    required String title,
    required String description,
    required String venue,
    required DateTime date,
    required DateTime time,
    required String category,
    required String organizer,
    bool isFeatured = false,
    double rating = 0.0,
    int maxParticipants = 0,
    bool isFree = true,
    double price = 0.0,
    String? requirements,
    File? imageFile,
    Uint8List? imageBytes,
    XFile? imageXFile,
  }) async {
    try {
      String? imageUrl;
      if (kIsWeb) {
        if (imageBytes != null || imageXFile != null) {
          imageUrl = await _uploadImageForWeb(bytes: imageBytes, xFile: imageXFile);
        }
      } else {
        if (imageFile != null) {
          imageUrl = await _uploadEventImage(imageFile);
        }
      }

      final eventRef = _firestore.collection('events').doc();
      final eventId = eventRef.id;

      final eventData = {
        'title': title,
        'description': description,
        'venue': venue,
        'date': Timestamp.fromDate(date),
        'time': Timestamp.fromDate(time),
        'organizer': organizer,
        'attendees': [],
        'imageUrl': imageUrl ?? '',
        'category': category,
        'isFeatured': isFeatured,
        'rating': rating,
        'maxParticipants': maxParticipants,
        'isFree': isFree,
        'price': price,
        'requirements': requirements ?? '',
        'registeredUsers': [],
        'favoritedBy': [], // This is already here, which is good
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      };

      await eventRef.set(eventData);
      return eventId;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String venue,
    required DateTime date,
    required DateTime time,
    required String category,
    required bool isFeatured,
    bool? isFree,
    double? price,
    int? maxParticipants,
    String? requirements,
    File? imageFile,
    Uint8List? imageBytes,
    XFile? imageXFile,
  }) async {
    try {
      String? imageUrl;
      final currentEvent = await getEventById(eventId);

      if (kIsWeb) {
        if (imageBytes != null || imageXFile != null) {
          imageUrl = await _uploadImageForWeb(bytes: imageBytes, xFile: imageXFile);
        }
      } else {
        if (imageFile != null) {
          imageUrl = await _uploadEventImage(imageFile);
        }
      }

      if (imageUrl == null && currentEvent != null) {
        imageUrl = currentEvent.imageUrl;
      }

      final updates = <String, dynamic>{
        'title': title,
        'description': description,
        'venue': venue,
        'date': Timestamp.fromDate(date),
        'time': Timestamp.fromDate(time),
        'category': category,
        'isFeatured': isFeatured,
        'updatedAt': Timestamp.now(),
      };

      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (isFree != null) updates['isFree'] = isFree;
      if (price != null) updates['price'] = price;
      if (maxParticipants != null) updates['maxParticipants'] = maxParticipants;
      if (requirements != null) updates['requirements'] = requirements;

      await _firestore.collection('events').doc(eventId).update(updates);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').orderBy('date', descending: false).snapshots().handleError((error) {
      return [];
    }).map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      } catch (e) {
        return [];
      }
    });
  }

  Future<String> _uploadEventImage(File imageFile) async {
    try {
      final fileName = 'event-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('event-images/$fileName');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists && doc.data() != null) {
        return Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<List<Event>> getFeaturedEvents() {
    return _firestore
        .collection('events')
        .where('isFeatured', isEqualTo: true)
        .where('date', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('date', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>)).toList());
  }

  Stream<List<Event>> getEventsByOrganizer(String organizerId) {
    return _firestore
        .collection('events')
        .where('organizer', isEqualTo: organizerId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>)).toList());
  }

  Stream<List<Event>> getEventsByCategory(String category) {
    if (category == 'All') {
      return getEvents();
    }
    return _firestore
        .collection('events')
        .where('category', isEqualTo: category)
        .where('date', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>)).toList());
  }

  Stream<List<Event>> searchEvents(String query) {
    if (query.isEmpty) return getEvents();
    return _firestore
        .collection('events')
        .where('date', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('title')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.where((doc) {
        try {
          final data = doc.data()! as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          final description = data['description']?.toString().toLowerCase() ?? '';
          final venue = data['venue']?.toString().toLowerCase() ?? '';
          final category = data['category']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase()) ||
              description.contains(query.toLowerCase()) ||
              venue.contains(query.toLowerCase()) ||
              category.contains(query.toLowerCase());
        } catch (e) {
          return false;
        }
      }).map((doc) => Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>)).toList();
    });
  }

  // FIXED: Added debug logging to see what's happening
  Future<void> toggleFavorite(String eventId, String userId) async {
    try {
      print('🟡 TOGGLE FAVORITE CALLED');
      print('🟡 Event ID: $eventId');
      print('🟡 User ID: $userId');
      print('🟡 Current user UID: ${_auth.currentUser?.uid}');

      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        print('🔴 Event not found in Firestore');
        throw Exception('Event not found');
      }

      final data = eventDoc.data() as Map<String, dynamic>;

      // Check what fields exist
      print('🟡 Event data fields:');
      data.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });

      List<dynamic> favoritedBy = List.from(data['favoritedBy'] ?? []);

      print('🟡 Current favoritedBy: $favoritedBy');
      print('🟡 Contains userId $userId: ${favoritedBy.contains(userId)}');

      if (favoritedBy.contains(userId)) {
        favoritedBy.remove(userId);
        print('🟡 Removed user from favorites');
      } else {
        favoritedBy.add(userId);
        print('🟡 Added user to favorites');
      }

      print('🟡 Updated favoritedBy: $favoritedBy');

      await _firestore.collection('events').doc(eventId).update({
        'favoritedBy': favoritedBy,
      });

      print('✅ Favorites updated successfully');

      // Verify the update
      final updatedDoc = await _firestore.collection('events').doc(eventId).get();
      final updatedData = updatedDoc.data() as Map<String, dynamic>;
      final updatedFavorites = List.from(updatedData['favoritedBy'] ?? []);
      print('✅ Verification - Updated favoritedBy: $updatedFavorites');

    } catch (e) {
      print('🔴 ERROR in toggleFavorite: $e');
      print('🔴 Stack trace: ${e.toString()}');
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // FIXED: Added debug logging
  Future<bool> isFavorite(String eventId, String userId) async {
    try {
      print('🟡 CHECKING IF FAVORITE');
      print('🟡 Event ID: $eventId');
      print('🟡 User ID: $userId');

      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        print('🔴 Event not found');
        return false;
      }

      final data = eventDoc.data() as Map<String, dynamic>;
      List<dynamic> favoritedBy = List.from(data['favoritedBy'] ?? []);

      print('🟡 favoritedBy array: $favoritedBy');
      print('🟡 Contains userId $userId: ${favoritedBy.contains(userId)}');

      return favoritedBy.contains(userId);
    } catch (e) {
      print('🔴 ERROR in isFavorite: $e');
      return false;
    }
  }

  // FIXED: Added debug logging and error handling
  Stream<List<Event>> getFavoriteEvents(String userId) {
    print('🟡 GET FAVORITE EVENTS STREAM');
    print('🟡 User ID: $userId');
    print('🟡 Current user UID: ${_auth.currentUser?.uid}');

    return _firestore
        .collection('events')
        .where('favoritedBy', arrayContains: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .handleError((error) {
      print('🔴 Firestore stream error in getFavoriteEvents: $error');
      return [];
    })
        .map((snapshot) {
      print('🟡 Favorite events snapshot received');
      print('🟡 Number of favorite events: ${snapshot.docs.length}');

      // Print each document to debug
      for (var doc in snapshot.docs) {
        print('  🔵 Document ID: ${doc.id}');
        print('  🔵 Data: ${doc.data()}');
      }

      if (snapshot.docs.isEmpty) {
        print('🟡 No favorite events found');
        return [];
      }

      return snapshot.docs.map((doc) {
        try {
          return Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>);
        } catch (e) {
          print('🔴 Error parsing favorite event ${doc.id}: $e');
          return null;
        }
      }).where((event) => event != null).cast<Event>().toList();
    });
  }

  Stream<List<Event>> getRegisteredEvents(String userId) {
    return _firestore
        .collection('events')
        .where('registeredUsers', arrayContains: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        try {
          return Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>);
        } catch (e) {
          return null;
        }
      }).where((event) => event != null).cast<Event>().toList();
    });
  }

  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) throw Exception('Event not found');
      final data = eventDoc.data() as Map<String, dynamic>;
      List<dynamic> registeredUsers = List.from(data['registeredUsers'] ?? []);
      final maxParticipants = data['maxParticipants'] as int? ?? 0;
      if (registeredUsers.contains(userId)) throw Exception('You are already registered for this event');
      if (maxParticipants > 0 && registeredUsers.length >= maxParticipants) throw Exception('Event is full');
      registeredUsers.add(userId);
      await _firestore.collection('events').doc(eventId).update({'registeredUsers': registeredUsers});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelRegistration(String eventId, String userId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) throw Exception('Event not found');
      final data = eventDoc.data() as Map<String, dynamic>;
      List<dynamic> registeredUsers = List.from(data['registeredUsers'] ?? []);
      registeredUsers.remove(userId);
      await _firestore.collection('events').doc(eventId).update({'registeredUsers': registeredUsers});
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserRegistered(String eventId, String userId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return false;
      final data = eventDoc.data() as Map<String, dynamic>;
      List<dynamic> registeredUsers = List.from(data['registeredUsers'] ?? []);
      return registeredUsers.contains(userId);
    } catch (e) {
      return false;
    }
  }

  Future<int> getRegistrationCount(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return 0;
      final data = eventDoc.data() as Map<String, dynamic>;
      List<dynamic> registeredUsers = List.from(data['registeredUsers'] ?? []);
      return registeredUsers.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  Stream<List<Event>> getUpcomingEvents() {
    final now = Timestamp.now();
    final thirtyDaysLater = Timestamp.fromDate(DateTime.now().add(const Duration(days: 30)));
    return _firestore
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: now)
        .where('date', isLessThanOrEqualTo: thirtyDaysLater)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>)).toList());
  }

  Stream<List<Event>> getPastEvents() {
    final now = Timestamp.now();
    return _firestore
        .collection('events')
        .where('date', isLessThan: now)
        .orderBy('date', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>)).toList());
  }

  Future<void> rateEvent(String eventId, double rating, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({'rating': rating});
    } catch (e) {
      throw Exception('Failed to rate event: $e');
    }
  }

  Stream<List<Event>> getEventsWithFilters({
    String? category,
    bool? isFeatured,
    bool? isFree,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore.collection('events');
    if (category != null && category != 'All') query = query.where('category', isEqualTo: category);
    if (isFeatured != null) query = query.where('isFeatured', isEqualTo: isFeatured);
    if (isFree != null) query = query.where('isFree', isEqualTo: isFree);
    if (startDate != null) query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    if (endDate != null) query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    return query.orderBy('date', descending: false).snapshots().map((snapshot) => snapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data()! as Map<String, dynamic>)).toList());
  }

  Future<void> addToFavorites(String eventId, String userId) => toggleFavorite(eventId, userId);
  Future<void> removeFromFavorites(String eventId, String userId) => toggleFavorite(eventId, userId);
  Future<void> registerForEventWithId(String eventId, String userId) => registerForEvent(eventId, userId);
  Future<void> unregisterFromEvent(String eventId, String userId) => cancelRegistration(eventId, userId);
  Future<bool> isEventFavorite(String eventId, String userId) => isFavorite(eventId, userId);
}