import '../../../core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

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

  Future<Map<String, dynamic>> unlikeRecipe(String recipeId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {'error': "Not authenticated"};
      }
      await _supabase
          .from('likes')
          .delete()
          .eq('recipe_id', recipeId)
          .eq('user_id', userId);

      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<bool> hasUserLiked(String recipeId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('likes')
          .select('id')
          .eq('recipe_id', recipeId)
          .eq('user_id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<int> getLikesCount(String recipeId) async {
    try {
      final response = await _supabase
          .from('likes')
          .select('id')
          .eq('recipe_id', recipeId);
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> addComment(
    String recipeId,
    String content,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {'error': 'Not authenticated'};
      }

      await _supabase.from('comments').insert({
        'recipe_id': recipeId,
        'user_id': userId,
        'content': content,
      });
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      await _supabase.from('comments').delete().eq('id', commentId);
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<List<CommentModel>> getComments(String recipeId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('''
            *,
            profiles: user_id(
            username,
            full_name,
            avatar_url)
            ''')
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((comment) => CommentModel.fromJson(comment))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
