class Member {
  final int? id;
  final String? username;
  final String? nickname;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? address;
  final String? birth; // LocalDate를 String으로 처리
  final String? gender; // Enum.Gender를 String으로 처리 ('M', 'F')
  final String? profileImage;
  final int? mateInfo;
  final String? createdAt; // Timestamp를 String으로 처리
  final String? updatedAt; // Timestamp를 String으로 처리

  Member({
    this.id,
    this.username,
    this.nickname,
    this.email,
    this.password,
    this.phoneNumber,
    this.address,
    this.birth,
    this.gender,
    this.profileImage,
    this.mateInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      birth: json['birth'], // String으로 받음
      gender: json['gender'], // String으로 받음
      profileImage: json['profileImage'],
      mateInfo: json['mateInfo'],
      createdAt: json['createdAt'], // String으로 받음
      updatedAt: json['updatedAt'], // String으로 받음
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'birth': birth,
      'gender': gender,
      'profileImage': profileImage,
      'mateInfo': mateInfo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}