class PostResponse {
  final int id;
  final String title;
  final String content;
  final String category;
  final String? postImg;
  final String writer;
  final int viewCount;
  final String createdAt;

  PostResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.postImg,
    required this.writer,
    required this.viewCount,
    required this.createdAt,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      postImg: json['postImg'],
      writer: json['writer'],
      viewCount: json['viewCount'],
      createdAt: json['createdAt'],
    );
  }
}
