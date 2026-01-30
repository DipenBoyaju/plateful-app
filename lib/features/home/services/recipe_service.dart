import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<List<RecipeModel>> getRecipes() async {
    try {
      final response = await _supabase
          .from('recipes')
          .select('''
            *,
            profiles:user_id (
              username,
              full_name,
              avatar_url
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((recipe) => RecipeModel.fromJson(recipe))
          .toList();
    } catch (e) {
      print('Error fetching recipes: $e');
      return [];
    }
  }

  Future<RecipeModel?> getRecipeById(String id) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select('''
            *,
            profiles:user_id (
              username,
              full_name,
              avatar_url,
              bio
            ),
            ingredients(*),
            instructions(*)
          ''')
          .eq('id', id)
          .single();

      return RecipeModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
