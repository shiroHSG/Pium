// lib/models/baby_profile.dart

import 'package:intl/intl.dart';

enum Gender { MALE, FEMALE }

class BabyProfile {
  int? childId;
  String name;
  DateTime birthDate;
  Gender? gender;
  double? height;             // cm
  double? weight;             // kg
  String? allergy;            // 알레르기
  String? developmentStep;    // 발달 단계

  BabyProfile({
    this.childId,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.height,
    this.weight,
    this.allergy,
    this.developmentStep,
  });

  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    return BabyProfile(
      childId: json['childId'],
      name: json['name'] ?? '', // null이면 빈 문자열
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : DateTime.now(), // 기본값으로 현재 시간 (또는 throw 처리 가능)
      gender: _parseGender(json['gender']),
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      allergy: json['allergy']?.toString(), // null 가능성 대비
      developmentStep: json['developmentStep']?.toString(), // null 가능성 대비
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
      if (allergy != null) 'allergy': allergy,
      if (developmentStep != null) 'developmentStep': developmentStep,
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
              developmentStep == other.developmentStep;

  @override
  int get hashCode =>
      name.hashCode ^
      birthDate.hashCode ^
      gender.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      allergy.hashCode ^
      developmentStep.hashCode;
}
