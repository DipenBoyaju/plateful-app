import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../models/profile_stats_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  ProfileStatsModel? _stats;
  bool _isLoading = false;
  String? _error;

  ProfileStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserStats(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _service.getUserStats(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String userId,
    String? fullName,
    String? bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.updateProfile(
      userId: userId,
      fullName: fullName,
      bio: bio,
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
}
