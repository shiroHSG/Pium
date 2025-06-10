// PostResponse: 백엔드로부터 데이터를 받아올 때 (예: 게시글 목록 조회, 특정 게시글 상세 조회) 사용합니다.
// //클라이언트에 보여줄 필요가 있는 정보(예: id, viewCount, createdAt, author의 닉네임 등)를 포함합니다. 서버에서 생성된 필드들이 포함될 수 있습니다.

class PostResponse {
  final int id;
  final String title;
  final String content;
  final String category;
  final String? postImg;  // String? -> null 허용
  final String author;
  final int viewCount;
  final String createdAt;

  PostResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.postImg,  // nullable이기 때문에 required 사용X
    required this.author,
    required this.viewCount,
    required this.createdAt,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      postImg: json['postImg'] as String?,
      author: json['author'] as String,
      viewCount: json['viewCount'] as int,
      createdAt: json['createdAt'] as String,
    );
  }
}
