import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MateApi {
  static const String baseUrl = 'http://10.0.2.2:8080'; // 실제 IP 또는 도메인으로 수정

  // 메이트 신청
  static Future<void> requestMate(int receiverId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.post(
      Uri.parse('$baseUrl/api/mate/request/$receiverId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // 성공: 토스트, 다이얼로그 등
      print("메이트 요청 성공");
    } else {
      print("메이트 요청 실패: ${response.body}");
    }
  }

  // 받은 요청 목록 조회
  static Future<List<Map<String, dynamic>>> fetchReceivedRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$baseUrl/api/mate/received'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => {
        'requestId': e['requestId'],
        'senderId': e['senderId'],
        'senderNickname': e['senderNickname'],
        'status': e['status'],
        'message': e['message'] ?? '',
        'updatedAt': e['updatedAt'],
      }).toList();
    } else {
      throw Exception('메이트 요청 조회 실패');
    }
  }

  // 요청 보낸 목록 조회
  static Future<List<Map<String, dynamic>>> fetchSentRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$baseUrl/api/mate/sent'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => {
        'requestId': e['requestId'],
        'senderId': e['senderId'],
        'senderNickname': e['senderNickname'],
        'status': e['status'],
        'message': e['message'] ?? '',
        'updatedAt': e['updatedAt'],
      }).toList();
    } else {
      throw Exception('보낸 요청 조회 실패');
    }
  }

  // 메이트 요청 응답
  static Future<void> respondMateRequest(int requestId, bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final endpoint = accepted
        ? '/api/mate/accept/$requestId'
        : '/api/mate/reject/$requestId';

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("메이트 요청 ${accepted ? '수락' : '거절'} 성공");
    } else {
      print("메이트 요청 응답 실패: ${response.body}");
      throw Exception('응답 실패');
    }
  }

  // 메이트 신청 취소
  static Future<void> cancelMateRequest(int requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8080/api/mate/cancel/$requestId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("요청 취소 실패: ${response.statusCode}");
    }
  }

}
