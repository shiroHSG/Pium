class SharingItem {
  final int id;
  final String title;
  final String content;
  final String? category;
  final String? imgUrl;
  final String author;
  final int viewCount;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;
  final int commentCount;

  SharingItem({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    this.imgUrl,
    required this.author,
    required this.viewCount,
    required this.createdAt,
    required this.likeCount,
    required this.isLiked,
    required this.commentCount,
  });

  factory SharingItem.fromJson(Map<String, dynamic> json) {
    return SharingItem(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      imgUrl: json['imgUrl'],
      author: json['author'],
      viewCount: json['viewCount'],
      createdAt: DateTime.parse(json['createdAt']),
      likeCount: json['likeCount'],
      isLiked: json['isLiked'],
      commentCount: json['commentCount'],
    );
  }
}
