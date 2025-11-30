import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';

class StorageService {
  static const String _activitiesKey = 'recent_activities';
  static const int _maxActivities = 5;

  static Future<void> saveActivity(Activity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final activities = await getActivities();

    // Add new activity at the beginning
    activities.insert(0, activity);

    // Keep only recent 5 activities
    if (activities.length > _maxActivities) {
      activities.removeRange(_maxActivities, activities.length);
    }

    // Convert to JSON and save
    final activitiesJson = activities.map((a) => a.toJson()).toList();
    await prefs.setString(_activitiesKey, json.encode(activitiesJson));
  }

  static Future<List<Activity>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString(_activitiesKey);

    if (activitiesJson != null) {
      try {
        final List<dynamic> data = json.decode(activitiesJson);
        return data.map((json) => Activity.fromJson(json)).toList();
      } catch (e) {
        print('Error parsing activities: $e');
      }
    }

    return [];
  }

  static Future<void> updateActivity(Activity activity) async {
    final activities = await getActivities();
    final index = activities.indexWhere((a) => a.id == activity.id);

    if (index != -1) {
      activities[index] = activity;

      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = activities.map((a) => a.toJson()).toList();
      await prefs.setString(_activitiesKey, json.encode(activitiesJson));
    }
  }

  static Future<void> deleteActivity(String activityId) async {
    final activities = await getActivities();
    activities.removeWhere((activity) => activity.id == activityId);

    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = activities.map((a) => a.toJson()).toList();
    await prefs.setString(_activitiesKey, json.encode(activitiesJson));
  }

  static Future<void> clearAllActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activitiesKey);
  }
}