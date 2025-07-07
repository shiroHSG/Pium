class PolicyResponse {
  final int id;
  final String title;
  final String content;
  final int viewCount;
  final String createdAt;
  final String updatedAt;

  PolicyResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PolicyResponse.fromJson(Map<String, dynamic> json) {
    return PolicyResponse(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      viewCount: json['viewCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
