class Comment {
  final int id;
  final int postId;
  final int memberId;
  final String content;
  final String createdAt;
  final String updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.memberId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      memberId: json['memberId'],
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'memberId': memberId,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
