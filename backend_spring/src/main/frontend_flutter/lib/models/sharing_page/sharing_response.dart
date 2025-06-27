class SharingResponse {
  final int id;
  final String title;
  final String content;
  final String category;
  final String? imgUrl;
  final String author;
  final int viewCount;
  final String createdAt;
  final int likeCount;
  final bool isLiked;

  SharingResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imgUrl,
    required this.author,
    required this.viewCount,
    required this.createdAt,
    required this.likeCount,
    required this.isLiked,
  });

  factory SharingResponse.fromJson(Map<String, dynamic> json) {
    return SharingResponse(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      imgUrl: json['imgUrl'],
      author: json['author'],
      viewCount: json['viewCount'],
      createdAt: json['createdAt'],
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }
}
