class PostLike {
  final int id;
  final int postId;
  final int memberId;

  PostLike({
    required this.id,
    required this.postId,
    required this.memberId,
  });

  factory PostLike.fromJson(Map<String, dynamic> json) {
    return PostLike(
      id: json['id'],
      postId: json['postId'],
      memberId: json['memberId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'memberId': memberId,
    };
  }
}
