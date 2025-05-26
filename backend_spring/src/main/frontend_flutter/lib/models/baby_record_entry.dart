// lib/models/baby_record_entry.dart
import 'dart:convert'; // jsonEncode, jsonDecode를 위해 추가

class BabyRecordEntry {
  final String title;
  final String publicContent; // '모두 공개' 내용
  final String privateContent; // '내 아이 일기' 내용
  final bool isPublic; // 공개 여부
  final DateTime createdAt; // <--- 새로 추가된 필드: 생성일자

  BabyRecordEntry({
    required this.title,
    required this.publicContent,
    required this.privateContent,
    required this.isPublic,
    required this.createdAt, // <--- 생성자에도 추가
  });

  // BabyRecordEntry 객체를 JSON 형태로 변환
  Map<String, dynamic> toJson() => {
    'title': title,
    'publicContent': publicContent,
    'privateContent': privateContent,
    'isPublic': isPublic,
    'createdAt': createdAt.toIso8601String(), // DateTime을 ISO 8601 문자열로 변환하여 저장
  };

  // JSON 데이터로부터 BabyRecordEntry 객체 생성
  factory BabyRecordEntry.fromJson(Map<String, dynamic> json) {
    return BabyRecordEntry(
      title: json['title'] as String,
      publicContent: json['publicContent'] as String,
      privateContent: json['privateContent'] as String,
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String), // 문자열을 DateTime으로 파싱
    );
  }
}