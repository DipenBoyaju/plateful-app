import '../../../core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<Map<String, dynamic>> likeRecipe(String recipeId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {'error': 'Not authenticated'};
      }

      await _supabase.from('likes').insert({
        'recipe_id': recipeId,
        'user_id': userId,
      });

      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
