class ChildProfile {
  String name;
  String dob;
  String? gender;
  String? height;
  String? weight;
  String? allergies;

  ChildProfile({
    required this.name,
    required this.dob,
    this.gender,
    this.height,
    this.weight,
    this.allergies,
  });

  ChildProfile copyWith({
    String? name,
    String? dob,
    String? gender,
    String? height,
    String? weight,
    String? allergies,
  }) {
    return ChildProfile(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChildProfile &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              dob == other.dob &&
              gender == other.gender &&
              height == other.height &&
              weight == other.weight &&
              allergies == other.allergies;

  @override
  int get hashCode =>
      name.hashCode ^
      dob.hashCode ^
      gender.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      allergies.hashCode;
}
