class SharingItem {
  final int id;
  final String name;
  final String content;
  final String? imageUrl;
  final String authorId;           // 작성자 닉네임 또는 아이디
  final int authorMemberId;        // ✅ 서버에서 내려주는 Member ID
  final int views;
  final String postDate;
  final String details;
  final int likes;
  final String category;
  final int likeCount;
  final bool isLiked;

  SharingItem({
    required this.id,
    required this.name,
    required this.content,
    this.imageUrl,
    required this.authorId,
    required this.authorMemberId,  // ✅ 생성자에 추가
    required this.views,
    required this.postDate,
    required this.details,
    required this.likes,
    required this.category,
    required this.likeCount,
    this.isLiked = false,
  });

  factory SharingItem.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    String formattedDate = '';

    if (createdAtRaw is String) {
      formattedDate = createdAtRaw.substring(0, 10);
    } else if (createdAtRaw is List && createdAtRaw.length >= 3) {
      formattedDate = '${createdAtRaw[0]}-${createdAtRaw[1].toString().padLeft(2, '0')}-${createdAtRaw[2].toString().padLeft(2, '0')}';
    }

    return SharingItem(
      id: json['id'],
      name: json['title'],
      content: json['content'],
      imageUrl: json['imgUrl'],
      authorId: json['author'],
      authorMemberId: json['authorMemberId'], // ✅ JSON에서 추출
      views: json['viewCount'] ?? 0,
      postDate: formattedDate,
      details: '조회수 ${json['viewCount'] ?? 0}회 · $formattedDate',
      likes: json['likes'] ?? 0,
        category: json['category'] ?? '나눔',
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }
}