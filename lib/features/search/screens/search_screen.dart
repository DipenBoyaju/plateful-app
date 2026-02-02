import 'package:flutter/material.dart';
import '../providers/search_provider.dart';
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
    Future.microtask(() {
      context.read<SearchProvider>().loadRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilteredBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _FilterBottomSheet(),
    );
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchProvider>().setSearchQuery(
                                  '',
                                );
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      context.read<SearchProvider>().setSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showFilteredBottomSheet,
                  icon: const Icon(Icons.tune),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),

          Consumer<SearchProvider>(
            builder: (context, provider, _) {
              final hasFilters =
                  provider.selectedDifficulty != 'All' ||
                  provider.maxCookTime != null ||
                  provider.sortBy != 'newest';

              if (!hasFilters) return const SizedBox.shrink();

              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (provider.selectedDifficulty != 'All')
                      Padding(
                        padding: const EdgeInsetsGeometry.only(right: 8),
                        child: Chip(
                          onDeleted: () {
                            provider.setDifficulty('All');
                          },
                          label: Text(provider.selectedDifficulty),
                        ),
                      ),
                    if (provider.maxCookTime != null)
                      Padding(
                        padding: const EdgeInsetsGeometry.only(right: 8),
                        child: Chip(
                          onDeleted: () {
                            provider.setMaxCookTime(null);
                          },
                          label: Text('Under ${provider.maxCookTime} min'),
                        ),
                      ),
                    if (provider.sortBy != 'newest')
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(_getSortLabel(provider.sortBy)),
                          onDeleted: () {
                            provider.setSortBy('newest');
                          },
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        provider.clearFilters();
                      },
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer<SearchProvider>(
              builder: (context, provider, _) {
                return Row(
                  children: [
                    Text(
                      '${provider.filteredRecipes.length} recipes found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadRecipes(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.filteredRecipes.isEmpty) {
                  return Center(
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
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadRecipes(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: provider.filteredRecipes.length,
                    itemBuilder: (context, index) {
                      return RecipeCard(
                        recipe: provider.filteredRecipes[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'oldest':
        return 'Oldest first';
      case 'quickest':
        return 'Quickest first';
      case 'longest':
        return 'Longest first';
      default:
        return 'Newest first';
    }
  }
}

class _FilterBottomSheet extends StatelessWidget {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Consumer<SearchProvider>(
          builder: (context, provider, _) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.clearFilters();
                      },
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Difficulty
                Text(
                  'Difficulty',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Easy', 'Medium', 'Hard'].map((difficulty) {
                    final isSelected =
                        provider.selectedDifficulty == difficulty;
                    return ChoiceChip(
                      label: Text(difficulty),
                      selected: isSelected,
                      onSelected: (selected) {
                        provider.setDifficulty(difficulty);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Cook Time
                Text(
                  'Maximum Cook Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Any'),
                      selected: provider.maxCookTime == null,
                      onSelected: (selected) {
                        provider.setMaxCookTime(null);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Under 15 min'),
                      selected: provider.maxCookTime == 15,
                      onSelected: (selected) {
                        provider.setMaxCookTime(selected ? 15 : null);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Under 30 min'),
                      selected: provider.maxCookTime == 30,
                      onSelected: (selected) {
                        provider.setMaxCookTime(selected ? 30 : null);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Under 60 min'),
                      selected: provider.maxCookTime == 60,
                      onSelected: (selected) {
                        provider.setMaxCookTime(selected ? 60 : null);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Sort By
                Text(
                  'Sort By',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<String>(
                  groupValue: provider.sortBy,
                  onChanged: (value) {
                    if (value != null) provider.setSortBy(value);
                  },
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Newest first'),
                        value: 'newest',
                      ),
                      RadioListTile<String>(
                        title: const Text('Oldest first'),
                        value: 'oldest',
                      ),
                      RadioListTile<String>(
                        title: const Text('Oldest first'),
                        value: 'oldest',
                      ),
                      RadioListTile<String>(
                        title: const Text('Quickest first'),
                        value: 'quickest',
                      ),
                      RadioListTile<String>(
                        title: const Text('Longest first'),
                        value: 'longest',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Apply button
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),

                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
}
