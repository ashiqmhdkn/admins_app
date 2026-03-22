class CommentModel {
  final String id;
  final String username;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.username,
    required this.text,
    required this.createdAt,
  });
}
