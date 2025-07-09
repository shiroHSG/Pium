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
  final String profileImageUrl;

  // ✅ 주소 정보 (시/군/구/동)
  final String addressCity;
  final String addressDistrict;
  final String addressDong;

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
    required this.profileImageUrl,
    required this.addressCity,
    required this.addressDistrict,
    required this.addressDong,
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
      profileImageUrl: json['profileImageUrl'] ?? '',
      // ✅ 주소 정보
      addressCity: json['addressCity'] ?? '',
      addressDistrict: json['addressDistrict'] ?? '',
      addressDong: json['addressDong'] ?? '',
    );
  }
}
