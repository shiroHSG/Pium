// PostResponse: 백엔드로부터 데이터를 받아올 때 (예: 게시글 목록 조회, 특정 게시글 상세 조회) 사용합니다.
// //클라이언트에 보여줄 필요가 있는 정보(예: id, viewCount, createdAt, author의 닉네임 등)를 포함합니다. 서버에서 생성된 필드들이 포함될 수 있습니다.

class PostResponse {
  final int id;
  final String title;
  final String content;
  final String category;
  final String? imgUrl;
  final String author;
  final int viewCount;
  final String createdAt;
  final int likeCount;
  final bool isLiked; // ⭐️ 추가
  final int commentCount;

  PostResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imgUrl,
    required this.author,
    required this.viewCount,
    required this.createdAt,
    required this.likeCount,
    required this.isLiked, // ⭐️
    required this.commentCount,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      imgUrl: json['imgUrl'],
      author: json['author'],
      viewCount: json['viewCount'],
      createdAt: json['createdAt'],
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false, // ⭐️
      commentCount: json['commentCount'] ?? 0,
    );
  }
}
