import 'package:flutter/material.dart';
import '../../home/models/recipe_model.dart';
import '../../home/services/recipe_service.dart';

class SearchProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  List<RecipeModel> _allRecipes = [];
  List<RecipeModel> _filteredRecipes = [];
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  int? _maxCookTime;
  String _sortBy = 'newest'; // newest, oldest, quickest, longest

  List<RecipeModel> get filteredRecipes => _filteredRecipes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedDifficulty => _selectedDifficulty;
  int? get maxCookTime => _maxCookTime;
  String get sortBy => _sortBy;

  Future<void> loadRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allRecipes = await _recipeService.getRecipes();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    _applyFilters();
  }

  void setMaxCookTime(int? time) {
    _maxCookTime = time;
    _applyFilters();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDifficulty = 'All';
    _maxCookTime = null;
    _sortBy = 'newest';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredRecipes = _allRecipes.where((recipe) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Difficulty filter
      final matchesDifficulty =
          _selectedDifficulty == 'All' ||
          recipe.difficulty == _selectedDifficulty;

      // Cook time filter
      final matchesCookTime =
          _maxCookTime == null || recipe.totalTime <= _maxCookTime!;

      return matchesSearch && matchesDifficulty && matchesCookTime;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'oldest':
        _filteredRecipes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'quickest':
        _filteredRecipes.sort((a, b) => a.totalTime.compareTo(b.totalTime));
        break;
      case 'longest':
        _filteredRecipes.sort((a, b) => b.totalTime.compareTo(a.totalTime));
        break;
      case 'newest':
      default:
        _filteredRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    notifyListeners();
  }
}
