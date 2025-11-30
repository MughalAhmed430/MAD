import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_model.dart';

class ApiService {
  // For USB debugging with physical device - use your computer's IP address
  static const String baseUrl = 'http://192.168.100.12:3000/api';
  // Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  // Get all activities
  static Future<List<Activity>> getActivities() async {
    try {
      print('Fetching activities from: $baseUrl/activities');
      final response = await http.get(
        Uri.parse('$baseUrl/activities'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Response data: $data');

        if (data['success'] == true) {
          final List<dynamic> activitiesData = data['data'];
          print('Found ${activitiesData.length} activities');
          return activitiesData.map((json) => Activity.fromJson(json)).toList();
        } else {
          throw Exception('API error: ${data['error']}');
        }
      } else {
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Create new activity
  static Future<Activity> createActivity(Activity activity) async {
    try {
      print('Creating activity at: $baseUrl/activities');
      final response = await http.post(
        Uri.parse('$baseUrl/activities'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': activity.title,
          'description': activity.description,
          'latitude': activity.latitude,
          'longitude': activity.longitude,
          'userId': activity.userId,
          'imageUrl': activity.imageUrl,
          'timestamp': activity.timestamp.toIso8601String(),
        }),
      );

      print('Create response status: ${response.statusCode}');
      print('Create response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          print('Activity created successfully: ${data['data']}');
          return Activity.fromJson(data['data']);
        } else {
          throw Exception('API error: ${data['error']}');
        }
      } else {
        throw Exception('Failed to create activity: ${response.statusCode}');
      }
    } catch (e) {
      print('Create activity error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Update activity
  static Future<Activity> updateActivity(Activity activity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/activities/${activity.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': activity.title,
          'description': activity.description,
          'latitude': activity.latitude,
          'longitude': activity.longitude,
          'imageUrl': activity.imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return Activity.fromJson(data['data']);
        } else {
          throw Exception('API error: ${data['error']}');
        }
      } else {
        throw Exception('Failed to update activity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete activity
  static Future<void> deleteActivity(String activityId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/activities/$activityId'),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception('API error: ${data['error']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Sync multiple activities
  static Future<void> syncActivities(List<Activity> activities) async {
    for (final activity in activities) {
      try {
        await createActivity(activity);
        print('Synced activity: ${activity.title}');
      } catch (e) {
        print('Failed to sync activity ${activity.title}: $e');
      }
    }
  }
}