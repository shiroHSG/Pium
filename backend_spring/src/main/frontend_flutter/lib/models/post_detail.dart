class PostDetail {
  final String title;
  final String content;
  final String authorId;
  final String category;
  final String date;
  final int likes;
  final int views;
  final List<Comment> comments;

  PostDetail({
    required this.title,
    required this.content,
    required this.authorId,
    required this.category,
    required this.date,
    required this.likes,
    required this.views,
    required this.comments,
  });
}

class Comment {
  final String author;
  final String text;

  Comment({
    required this.author,
    required this.text,
  });
}