import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/social_service.dart';

class SocialProvider extends ChangeNotifier {
  final SocialService _service = SocialService();

  final Map<String, bool> _likedRecipes = {};
  final Map<String, int> _likeCounts = {};
  final Map<String, List<CommentModel>> _comments = {};
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

  Future<void> toggleLike(String recipeId) async {
    final currentlyLiked = _likedRecipes[recipeId] ?? false;

    // Optimistic update
    _likedRecipes[recipeId] = !currentlyLiked;
    _likeCounts[recipeId] =
        (_likeCounts[recipeId] ?? 0) + (currentlyLiked ? -1 : 1);
    notifyListeners();

    // Make API call
    final result = currentlyLiked
        ? await _service.unlikeRecipe(recipeId)
        : await _service.likeRecipe(recipeId);

    if (result['error'] != null) {
      // Revert on error
      _likedRecipes[recipeId] = currentlyLiked;
      _likeCounts[recipeId] =
          (_likeCounts[recipeId] ?? 0) + (currentlyLiked ? 1 : -1);
      _error = result['error'];
      notifyListeners();
    }
  }

  Future<bool> addComment(String recipeId, String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.addComment(recipeId, content);

    if (result['error'] != null) {
      _error = result['error'];
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Reload comments
    await _loadComments(recipeId);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> deleteComment(String recipeId, String commentId) async {
    await _service.deleteComment(commentId);
    await _loadComments(recipeId);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
