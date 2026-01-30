class RecipeModel {
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

  RecipeModel({
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
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'];

    return RecipeModel(
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
    );
  }

  int get totalTime => prepTime + cookTime;
}
