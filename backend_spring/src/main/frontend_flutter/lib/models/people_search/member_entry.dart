class Member {
  final int id;
  final String nickname;
  final String address;
  final String? profileImageUrl;

  Member({
    required this.id,
    required this.nickname,
    required this.address,
    this.profileImageUrl,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      nickname: json['nickname'],
      address: json['address'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}
