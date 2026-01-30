import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/create_recipe_provider.dart';
import '../../recipe_detail/screens/recipe_detail_screen.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _prepTime = 15;
  int _cookTime = 30;
  int _servings = 4;
  String _difficulty = 'Medium';

  File? _imageFile;
  final List<Map<String, TextEditingController>> _ingredients = [
    {'quantity': TextEditingController(), 'item': TextEditingController()},
  ];
  final List<TextEditingController> _instructions = [TextEditingController()];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var ingredient in _ingredients) {
      ingredient['quantity']?.dispose();
      ingredient['item']?.dispose();
    }
    for (var instruction in _instructions) {
      instruction.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({
        'quantity': TextEditingController(),
        'item': TextEditingController(),
      });
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index]['quantity']?.dispose();
      _ingredients[index]['item']?.dispose();
      _ingredients.removeAt(index);
    });
  }

  void _addInstruction() {
    setState(() {
      _instructions.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructions[index].dispose();
      _instructions.removeAt(index);
    });
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate ingredients
    if (_ingredients.any(
      (i) => i['quantity']!.text.isEmpty || i['item']!.text.isEmpty,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all ingredients')),
      );
      return;
    }

    // Validate instructions
    if (_instructions.any((i) => i.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all instruction steps')),
      );
      return;
    }

    final provider = context.read<CreateRecipeProvider>();

    final ingredients = _ingredients.map((i) {
      return {'quantity': i['quantity']!.text, 'item': i['item']!.text};
    }).toList();

    final instructions = _instructions.map((i) => i.text).toList();

    final recipeId = await provider.createRecipe(
      title: _titleController.text,
      description: _descriptionController.text,
      prepTime: _prepTime,
      cookTime: _cookTime,
      servings: _servings,
      difficulty: _difficulty,
      ingredients: ingredients,
      instructions: instructions,
      imageFile: _imageFile,
    );

    if (recipeId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipeId: recipeId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Recipe')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Upload
            Card(
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add recipe image',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Basic Information
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title',
                hintText: 'e.g., Spaghetti Carbonara',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of your recipe...',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Time and Servings
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prep Time (min)'),
                      Slider(
                        value: _prepTime.toDouble(),
                        min: 5,
                        max: 180,
                        divisions: 35,
                        label: '$_prepTime min',
                        onChanged: (value) {
                          setState(() {
                            _prepTime = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cook Time (min)'),
                      Slider(
                        value: _cookTime.toDouble(),
                        min: 5,
                        max: 180,
                        divisions: 35,
                        label: '$_cookTime min',
                        onChanged: (value) {
                          setState(() {
                            _cookTime = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Servings'),
                      Slider(
                        value: _servings.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: '$_servings',
                        onChanged: (value) {
                          setState(() {
                            _servings = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    items: ['Easy', 'Medium', 'Hard'].map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _difficulty = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Ingredients
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: ingredient['quantity'],
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: '2 cups',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: ingredient['item'],
                        decoration: const InputDecoration(
                          labelText: 'Ingredient',
                          hintText: 'Flour',
                        ),
                      ),
                    ),
                    if (index > 0)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeIngredient(index),
                        color: Colors.red,
                      ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Instructions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Instructions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addInstruction,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._instructions.asMap().entries.map((entry) {
              final index = entry.key;
              final instruction = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: instruction,
                        decoration: InputDecoration(
                          labelText: 'Step ${index + 1}',
                          hintText: 'Describe this step...',
                        ),
                        maxLines: 3,
                      ),
                    ),
                    if (index > 0)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeInstruction(index),
                        color: Colors.red,
                      ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Error message
            Consumer<CreateRecipeProvider>(
              builder: (context, provider, _) {
                if (provider.error != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Submit button
            Consumer<CreateRecipeProvider>(
              builder: (context, provider, _) {
                return FilledButton(
                  onPressed: provider.isLoading ? null : _submitRecipe,
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publish Recipe'),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
