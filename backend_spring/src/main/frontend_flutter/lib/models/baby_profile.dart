import 'package:intl/intl.dart';

enum Gender { MALE, FEMALE }

class BabyProfile {
  int? childId;
  String name;
  DateTime birthDate;
  Gender? gender;
  double? height;
  double? weight;
  String? allergy;
  String? developmentStep;
  final String? profileImageUrl; // ✅ 이미지 경로 필드

  BabyProfile({
    this.childId,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.height,
    this.weight,
    this.allergy,
    this.developmentStep,
    this.profileImageUrl, // ✅ 생성자에 포함
  });

  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    final birthList = json['birth'] ?? json['birthDate']; // 둘 다 대응
    DateTime parsedBirth;

    if (birthList is List && birthList.length >= 3) {
      parsedBirth = DateTime(birthList[0], birthList[1], birthList[2]);
    } else if (birthList is String) {
      parsedBirth = DateTime.tryParse(birthList) ?? DateTime.now();
    } else {
      parsedBirth = DateTime.now();
    }

    return BabyProfile(
      childId: json['childId'] ?? json['id'],
      name: json['name'] ?? '',
      birthDate: parsedBirth,
      gender: _parseGender(json['gender']),
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      allergy: json['sensitiveInfo']?.toString(),
      developmentStep: json['developmentStep']?.toString(),
      profileImageUrl: json['profileImgUrl']?.toString(),
    );
  }
  static Gender? _parseGender(dynamic value) {
    if (value == null) return null;
    if (value == 'M' || value == '남자') return Gender.MALE;
    if (value == 'F' || value == '여자') return Gender.FEMALE;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (childId != null) 'childId': childId,
      'name': name,
      'birth': DateFormat('yyyy-MM-dd').format(birthDate),
      'gender': gender == Gender.MALE ? 'M' : 'F',
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (allergy != null) 'sensitiveInfo': allergy,
      if (developmentStep != null) 'developmentStep': developmentStep,
      if (profileImageUrl != null && profileImageUrl!.startsWith('/uploads'))
        'profileImgUrl': profileImageUrl, // ✅ 서버 저장 경로만 전송
    };
  }

  BabyProfile copyWith({
    int? childId,
    String? name,
    DateTime? birthDate,
    Gender? gender,
    double? height,
    double? weight,
    String? allergy,
    String? developmentStep,
    String? profileImageUrl, // ✅ 추가
  }) {
    return BabyProfile(
      childId: childId ?? this.childId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergy: allergy ?? this.allergy,
      developmentStep: developmentStep ?? this.developmentStep,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl, // ✅ 추가
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BabyProfile &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              birthDate == other.birthDate &&
              gender == other.gender &&
              height == other.height &&
              weight == other.weight &&
              allergy == other.allergy &&
              developmentStep == other.developmentStep &&
              profileImageUrl == other.profileImageUrl; // ✅ 비교 추가

  @override
  int get hashCode =>
      name.hashCode ^
      birthDate.hashCode ^
      gender.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      allergy.hashCode ^
      developmentStep.hashCode ^
      profileImageUrl.hashCode; // ✅ 해시 추가
}
