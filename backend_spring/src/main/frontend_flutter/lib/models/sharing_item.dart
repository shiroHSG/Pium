const String baseUrl = 'https://pium.store';

class SharingItem {
  final int id;
  final String name;
  final String content;
  final String? imageUrl;  // 원본 서버에서 오는 이미지 경로(상대/절대 가능)
  final String authorId;
  final int authorMemberId;
  final int views;
  final String postDate;
  final String details;
  final int likes;
  final String category;
  final int likeCount;
  final bool isLiked;
  final String addressCity;
  final String addressDistrict;
  final String addressDong;

  SharingItem({
    required this.id,
    required this.name,
    required this.content,
    this.imageUrl,
    required this.authorId,
    required this.authorMemberId,
    required this.views,
    required this.postDate,
    required this.details,
    required this.likes,
    required this.category,
    required this.likeCount,
    this.isLiked = false,
    required this.addressCity,
    required this.addressDistrict,
    required this.addressDong,
  });

  /// 실제 이미지 표시용 "http://..."가 붙은 전체 url
  String get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    if (imageUrl!.startsWith('http')) return imageUrl!;
    return '$baseUrl$imageUrl'; // 상대경로면 BASE_URL 붙여줌
  }

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
      authorMemberId: json['authorMemberId'],
      views: json['viewCount'] ?? 0,
      postDate: formattedDate,
      details: '조회수 ${json['viewCount'] ?? 0}회 · $formattedDate',
      likes: json['likes'] ?? 0,
      category: json['category'] ?? '나눔',
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      addressCity: json['addressCity'] ?? '',
      addressDistrict: json['addressDistrict'] ?? '',
      addressDong: json['addressDong'] ?? '',
    );
  }
}
