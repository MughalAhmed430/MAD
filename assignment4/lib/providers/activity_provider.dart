import 'package:flutter/foundation.dart';
import '../models/activity_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ActivityProvider with ChangeNotifier {
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;
  bool _isOnline = true;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  ActivityProvider() {
    print('ActivityProvider initialized');
    _checkConnectivity();
    loadActivities();
  }

  Future<void> _checkConnectivity() async {
    _isOnline = true;
    print('Connectivity status: Online');
    notifyListeners();
  }

  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isOnline) {
        print('Loading activities from API...');
        final apiActivities = await ApiService.getActivities();
        print('Loaded ${apiActivities.length} activities from API');
        _activities = apiActivities;

        for (final activity in apiActivities) {
          await StorageService.saveActivity(activity);
        }
        print('Saved ${apiActivities.length} activities to local storage');
      } else {
        print('Loading activities from local storage');
        _activities = await StorageService.getActivities();
        print('Loaded ${_activities.length} activities from local storage');
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading activities: $e');
      _activities = await StorageService.getActivities();
      print('Fallback: Loaded ${_activities.length} activities from local storage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(Activity activity) async {
    print('ADD ACTIVITY METHOD CALLED!');
    print('Activity details - Title: ${activity.title}, Description: ${activity.description}');

    _isLoading = true;
    notifyListeners();

    try {
      print('1. Saving to local storage: "${activity.title}"');
      await StorageService.saveActivity(activity);
      _activities.insert(0, activity);
      print('   Local storage save successful');

      print('2. Online status: $_isOnline');
      if (_isOnline) {
        print('3. Calling API service...');
        try {
          print('   Sending activity to API...');
          final createdActivity = await ApiService.createActivity(activity);
          print('4. API success: "${createdActivity.title}" with ID: ${createdActivity.id}');

          final index = _activities.indexWhere((a) => a.id == activity.id);
          if (index != -1) {
            _activities[index] = createdActivity;
            print('   Updated local activity with server ID');
          }
        } catch (e) {
          print('4. API failed: $e');
          print('   Activity saved locally only due to API failure');
        }
      } else {
        print('3. Offline mode - Skipping API call');
      }

      _error = null;
      print('Activity added successfully! Total activities: ${_activities.length}');
    } catch (e) {
      _error = e.toString();
      print('Add activity error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateActivity(Activity activity) async {
    print('Updating activity: ${activity.title}');
    try {
      await StorageService.updateActivity(activity);
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
        print('Activity updated locally');
      }

      if (_isOnline) {
        try {
          await ApiService.updateActivity(activity);
          print('Activity updated on API');
        } catch (e) {
          print('API update sync failed: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Update activity error: $e');
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String activityId) async {
    print('Deleting activity: $activityId');
    try {
      await StorageService.deleteActivity(activityId);
      _activities.removeWhere((activity) => activity.id == activityId);
      print('Activity deleted locally');

      if (_isOnline) {
        try {
          await ApiService.deleteActivity(activityId);
          print('Activity deleted from API');
        } catch (e) {
          print('API delete sync failed: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Delete activity error: $e');
      notifyListeners();
    }
  }

  Future<void> syncAllActivities() async {
    if (!_isOnline) return;

    print('Syncing all activities with API...');
    try {
      final localActivities = await StorageService.getActivities();
      print('Found ${localActivities.length} local activities to sync');
      await ApiService.syncActivities(localActivities);

      await loadActivities();
      print('Sync completed successfully');
    } catch (e) {
      _error = 'Sync failed: $e';
      print('Sync error: $e');
      notifyListeners();
    }
  }

  List<Activity> searchActivities(String query) {
    if (query.isEmpty) return _activities;

    final results = _activities.where((activity) {
      return activity.title.toLowerCase().contains(query.toLowerCase()) ||
          activity.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    print('Search for "$query" returned ${results.length} results');
    return results;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setOnlineStatus(bool online) {
    _isOnline = online;
    print('Online status changed to: $online');
    notifyListeners();

    if (online) {
      syncAllActivities();
    }
  }
}