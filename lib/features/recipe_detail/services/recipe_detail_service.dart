import 'package:plateful_app/features/recipe_detail/models/recipe_detail_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class RecipeDetailService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<RecipeDetailModel?> getRecipeById(String id) async {
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
      return RecipeDetailModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
