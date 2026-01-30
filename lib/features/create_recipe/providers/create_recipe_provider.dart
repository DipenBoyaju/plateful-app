import 'dart:io';
import 'package:flutter/material.dart';
import '../services/create_recipe_service.dart';

class CreateRecipeProvider extends ChangeNotifier {
  final CreateRecipeService _service = CreateRecipeService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> createRecipe({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.createRecipe(
      title: title,
      description: description,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      difficulty: difficulty,
      ingredients: ingredients,
      instructions: instructions,
      imageFile: imageFile,
    );

    _isLoading = false;

    if (result['error'] != null) {
      _error = result['error'];
      notifyListeners();
      return null;
    }

    notifyListeners();
    return result['recipeId'] as String;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
