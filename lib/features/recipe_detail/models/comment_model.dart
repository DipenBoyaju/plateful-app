class CommentModel {
  final String id;
  final String recipeId;
  final String userId;
  final String content;
  final String createdAt;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatar;

  CommentModel({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'];

    return CommentModel(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      userId: json['user_id'],
      content: json['content'],
      createdAt: json['created_at'],
      authorName: profiles?['full_name'] as String,
      authorUsername: profiles?['username'] as String,
      authorAvatar: profiles?['author_url'] as String,
    );
  }
}
