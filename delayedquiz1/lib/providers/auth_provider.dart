import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthServiceProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final error = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );

    _isLoading = false;

    if (error != null) {
      _error = error;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final error = await _authService.signIn(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (error != null) {
      _error = error;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final error = await _authService.resetPassword(email);

    _isLoading = false;

    if (error != null) {
      _error = error;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}