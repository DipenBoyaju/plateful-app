import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class CreateRecipeService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<Map<String, dynamic>> createRecipe({
    required String title,
    required String description,
    required int prepTime,
    required int cookTime,
    required int servings,
    required String difficulty,
    required List<Map<String, String>> ingredients,
    required List<String> instructions,
    File? imageFile,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'error': 'You must be logged in to create a recipe'};
      }

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        final fileExt = imageFile.path.split('.').last;
        final fileName =
            '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await _supabase.storage
            .from('recipe-images')
            .upload(fileName, imageFile);

        imageUrl = _supabase.storage
            .from('recipe-images')
            .getPublicUrl(fileName);
      }

      // Create recipe
      final recipeResponse = await _supabase
          .from('recipes')
          .insert({
            'user_id': user.id,
            'title': title,
            'description': description,
            'image_url': imageUrl,
            'prep_time': prepTime,
            'cook_time': cookTime,
            'servings': servings,
            'difficulty': difficulty,
          })
          .select()
          .single();

      final recipeId = recipeResponse['id'] as String;

      // Create ingredients
      final ingredientsData = ingredients.asMap().entries.map((entry) {
        return {
          'recipe_id': recipeId,
          'item': entry.value['item'],
          'quantity': entry.value['quantity'],
          'order_index': entry.key,
        };
      }).toList();

      await _supabase.from('ingredients').insert(ingredientsData);

      // Create instructions
      final instructionsData = instructions.asMap().entries.map((entry) {
        return {
          'recipe_id': recipeId,
          'step_number': entry.key + 1,
          'description': entry.value,
        };
      }).toList();

      await _supabase.from('instructions').insert(instructionsData);

      return {'success': true, 'recipeId': recipeId};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
