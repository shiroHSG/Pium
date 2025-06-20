class SharingItem {
  final int id;
  final String name;
  final String content;
  final String? imageUrl;
  final String authorId;
  final int views;
  final String postDate;
  final String details;

  SharingItem({
    required this.id,
    required this.name,
    required this.content,
    this.imageUrl,
    required this.authorId,
    required this.views,
    required this.postDate,
    required this.details,
  });

  factory SharingItem.fromJson(Map<String, dynamic> json) {
    return SharingItem(
      id: json['id'],
      name: json['title'],
      content: json['content'],
      imageUrl: json['imgUrl'],
      authorId: json['author'],
      views: json['viewCount'] ?? 0,
      postDate: json['createdAt']?.substring(0, 10) ?? '',
      details: '조회수 ${json['viewCount'] ?? 0}회 · ${json['createdAt']?.substring(0, 10) ?? ''}', // 임시 생성 방식
    );
  }
}
