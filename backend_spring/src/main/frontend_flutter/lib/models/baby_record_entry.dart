import 'dart:convert';

class BabyRecordEntry {
  final String title;
  final String publicContent;
  final String privateContent;
  final bool isPublic;
  final DateTime createdAt;

  BabyRecordEntry({
    required this.title,
    required this.publicContent,
    required this.privateContent,
    required this.isPublic,
    required this.createdAt,
  });

  // BabyRecordEntry 객체를 JSON 형태로 변환
  Map<String, dynamic> toJson() => {
    'title': title,
    'publicContent': publicContent,
    'privateContent': privateContent,
    'isPublic': isPublic,
    'createdAt': createdAt.toIso8601String(),
  };

  // JSON 데이터로부터 BabyRecordEntry 객체 생성
  factory BabyRecordEntry.fromJson(Map<String, dynamic> json) {
    return BabyRecordEntry(
      title: json['title'] as String,
      publicContent: json['publicContent'] as String,
      privateContent: json['privateContent'] as String,
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}