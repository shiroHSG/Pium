class Comment {
  final int id;
  final String content;
  final String writer;
  final String createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.writer,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      writer: json['writer'],
      createdAt: json['createdAt'],
    );
  }
}