import 'package:flutter/material.dart';
import 'package:plateful_app/features/recipe_detail/models/comment_model.dart';
import '../services/social_service.dart';

class SocialProvider extends ChangeNotifier {
  final SocialService _service = SocialService();

  Map<String, bool> _likedRecipes = {};
  Map<String, int> _likeCounts = {};
  Map<String, List<CommentModel>> _comments = {};
  bool _isLoading = false;
  String? _error;

  bool isLiked(String recipeId) => _likedRecipes[recipeId] ?? false;
  int getLikesCount(String recipeId) => _likeCounts[recipeId] ?? 0;
  List<CommentModel> getComments(String recipeId) => _comments[recipeId] ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecipeData(String recipeId) async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _checkLikeStatus(recipeId),
      _loadLikesCount(recipeId),
      _loadComments(recipeId),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkLikeStatus(String recipeId) async {
    final liked = await _service.hasUserLiked(recipeId);
    _likedRecipes[recipeId] = liked;
  }

  Future<void> _loadLikesCount(String recipeId) async {
    final count = await _service.getLikesCount(recipeId);
    _likeCounts[recipeId] = count;
  }

  Future<void> _loadComments(String recipeId) async {
    final comments = await _service.getComments(recipeId);
    _comments[recipeId] = comments;
  }
}
