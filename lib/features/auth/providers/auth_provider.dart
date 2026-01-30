import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _authService.isLoggedIn;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserProfile(session.user.id);
      } else {
        _user = null;
        notifyListeners();
      }
    });

    // Load current user if logged in
    if (_authService.isLoggedIn) {
      _loadUserProfile(_authService.currentUser!.id);
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    _user = await _authService.getUserProfile(userId);
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
      username: username,
    );

    _isLoading = false;

    if (result['error'] != null) {
      _error = result['error'];
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.signIn(email: email, password: password);

    _isLoading = false;

    if (result['error'] != null) {
      _error = result['error'];
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
