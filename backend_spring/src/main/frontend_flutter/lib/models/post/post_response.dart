import '../util/parse_date_time.dart';

class PostResponse {
  final int id;
  final String title;
  final String content;
  final String category;
  final String imageUrl;
  final String author;
  final int viewCount;
  final DateTime? createdAt;
  final bool isLiked;
  final int likeCount;
  final int commentCount;

  PostResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.author,
    required this.viewCount,
    required this.createdAt,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      imageUrl: json['imageUrl'] ?? '',
      author: json['author'],
      viewCount: json['viewCount'] ?? 0,
      createdAt: parseDateTime(json['createdAt']),
      isLiked: json['isLiked'] ?? false,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
    );
  }
}
