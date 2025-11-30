import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPosition = await LocationService.getCurrentLocation();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentPosition = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startTracking() {
    _isTracking = true;
    _error = null;
    notifyListeners();

    LocationService.getLocationStream().listen(
          (Position position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isTracking = false;
        notifyListeners();
      },
    );
  }

  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}