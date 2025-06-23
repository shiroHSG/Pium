import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 멤버 DTO
class ChatRoomMember {
  final int memberId;
  final String nickname;
  final String profileImageUrl;
  final bool isAdmin;

  ChatRoomMember({
    required this.memberId,
    required this.nickname,
    required this.profileImageUrl,
    required this.isAdmin,
  });

  factory ChatRoomMember.fromJson(Map<String, dynamic> json) {
    return ChatRoomMember(
      memberId: json['memberId'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'] ?? '',
      isAdmin: json['isAdmin'],
    );
  }
}