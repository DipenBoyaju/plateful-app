import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_stats_model.dart';
import '../../../core/config/supabase_config.dart';

class ProfileService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<ProfileStatsModel> getUserStats(String userId) async {
    try {
      final recipesResponse = await _supabase
          .from('recipes')
          .select('id')
          .eq('user_id', userId);

      final recipesCount = (recipesResponse as List).length;

      return ProfileStatsModel(
        recipesCount: recipesCount,
        followersCount: 0,
        followingCount: 0,
      );
    } catch (e) {
      return ProfileStatsModel(
        recipesCount: 0,
        followersCount: 0,
        followingCount: 0,
      );
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? bio,
  }) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            if (fullName != null) 'full_name': fullName,
            if (bio != null) 'bio': bio,
          })
          .eq('id', userId);
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
