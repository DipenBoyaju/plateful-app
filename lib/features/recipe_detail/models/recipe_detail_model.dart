class IngredientModel {
  final String id;
  final String recipeId;
  final String item;
  final String quantity;
  final int orderIndex;

  IngredientModel({
    required this.id,
    required this.recipeId,
    required this.item,
    required this.quantity,
    required this.orderIndex,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      item: json['item'] as String,
      quantity: json['quantity'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}

class InstructionModel {
  final String id;
  final String recipeId;
  final int stepNumber;
  final String description;

  InstructionModel({
    required this.id,
    required this.recipeId,
    required this.stepNumber,
    required this.description,
  });

  factory InstructionModel.fromJson(Map<String, dynamic> json) {
    return InstructionModel(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      stepNumber: json['step_number'] as int,
      description: json['description'] as String,
    );
  }
}

class RecipeDetailModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String? imageUrl;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final String createdAt;

  // Author info
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatar;
  final String? authorBio;

  // Related data
  final List<IngredientModel> ingredients;
  final List<InstructionModel> instructions;

  RecipeDetailModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.createdAt,
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
    this.authorBio,
    required this.ingredients,
    required this.instructions,
  });

  factory RecipeDetailModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'];

    final ingredientsList = json['ingredients'] as List? ?? [];
    final ingredients =
        ingredientsList.map((i) => IngredientModel.fromJson(i)).toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final instructionsList = json['instructions'] as List? ?? [];
    final instructions =
        instructionsList.map((i) => InstructionModel.fromJson(i)).toList()
          ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));

    return RecipeDetailModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      prepTime: json['prep_time'] as int? ?? 0,
      cookTime: json['cook_time'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      difficulty: json['difficulty'] as String? ?? 'Medium',
      createdAt: json['created_at'] as String? ?? '',
      authorName: profiles?['full_name'] as String?,
      authorUsername: profiles?['username'] as String?,
      authorAvatar: profiles?['avatar_url'] as String?,
      authorBio: profiles?['bio'] as String?,
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  int get totalTime => prepTime + cookTime;
}
