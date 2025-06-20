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
    final createdAtRaw = json['createdAt'];
    String formattedDate = '';

    if (createdAtRaw is String) {
      formattedDate = createdAtRaw.substring(0, 10);
    } else if (createdAtRaw is List && createdAtRaw.length >= 3) {
      final year = createdAtRaw[0];
      final month = createdAtRaw[1].toString().padLeft(2, '0');
      final day = createdAtRaw[2].toString().padLeft(2, '0');
      formattedDate = '$year-$month-$day';
    }

    return SharingItem(
      id: json['id'],
      name: json['title'],
      content: json['content'],
      imageUrl: json['imgUrl'],
      authorId: json['author'],
      views: json['viewCount'] ?? 0,
      postDate: formattedDate,
      details: '조회수 ${json['viewCount'] ?? 0}회 · $formattedDate',
    );
  }
}
