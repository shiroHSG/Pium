import '../util/parse_date_time.dart';

class PostResponse {
  final int id;
  final String title;
  final String content;
  final String category;
  final String imgUrl;
  final String author;
  final int viewCount;
  final DateTime? createdAt;

  PostResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imgUrl,
    required this.author,
    required this.viewCount,
    required this.createdAt,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      imgUrl: json['imgUrl'] ?? '', // null 대비
      author: json['author'],
      viewCount: json['viewCount'] ?? 0,
      createdAt: parseDateTime(json['createdAt']),
    );
  }
}
