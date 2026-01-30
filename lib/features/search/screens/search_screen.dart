import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/providers/recipe_provider.dart';
import '../../home/widgets/recipe_card.dart';
import '../../home/models/recipe_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedDifficulty = 'All';
  List<RecipeModel> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    final recipes = context.read<RecipeProvider>().recipes;
    setState(() {
      _filteredRecipes = recipes;
    });
  }

  void _filterRecipes(String query) {
    final recipes = context.read<RecipeProvider>().recipes;
    setState(() {
      _filteredRecipes = recipes.where((recipe) {
        final matchesSearch =
            recipe.title.toLowerCase().contains(query.toLowerCase()) ||
            recipe.description.toLowerCase().contains(query.toLowerCase());
        final matchesDifficulty =
            _selectedDifficulty == 'All' ||
            recipe.difficulty == _selectedDifficulty;
        return matchesSearch && matchesDifficulty;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Recipes')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterRecipes('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterRecipes,
            ),
          ),

          // Difficulty filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Easy', 'Medium', 'Hard'].map((difficulty) {
                  final isSelected = _selectedDifficulty == difficulty;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(difficulty),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDifficulty = difficulty;
                          _filterRecipes(_searchController.text);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results
          Expanded(
            child: _filteredRecipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recipes found',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      return RecipeCard(recipe: _filteredRecipes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
