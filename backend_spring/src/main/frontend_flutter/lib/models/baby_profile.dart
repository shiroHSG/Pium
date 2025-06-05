class BabyProfile {
  String name;
  String dob;
  String? gender;
  String? height;      // cm
  String? weight;      // kg
  String? allergies;
  String? development; // 발달 단계 등 추가 필드

  BabyProfile({
    required this.name,
    required this.dob,
    this.gender,
    this.height,
    this.weight,
    this.allergies,
    this.development,
  });

  BabyProfile copyWith({
    String? name,
    String? dob,
    String? gender,
    String? height,
    String? weight,
    String? allergies,
    String? development,
  }) {
    return BabyProfile(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
      development: development ?? this.development,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BabyProfile &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              dob == other.dob &&
              gender == other.gender &&
              height == other.height &&
              weight == other.weight &&
              allergies == other.allergies &&
              development == other.development;

  @override
  int get hashCode =>
      name.hashCode ^
      dob.hashCode ^
      gender.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      allergies.hashCode ^
      development.hashCode;
}
