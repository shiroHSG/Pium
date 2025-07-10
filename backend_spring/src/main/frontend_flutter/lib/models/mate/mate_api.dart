// ✅ mate_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MateApi {
  static const String baseUrl = 'https://pium.store';

  // Mate 신청
  static Future<void> requestMate(int receiverId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    await http.post(
      Uri.parse('$baseUrl/api/mate/request/$receiverId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // Mate 받은 요청 조회
  static Future<List<Map<String, dynamic>>> fetchReceivedRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final response = await http.get(
      Uri.parse('$baseUrl/api/mate/received'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => {
        'requestId': e['requestId'],
        'senderUsername': e['senderUsername'] ?? '',
        'senderNickname': e['senderNickname'] ?? '',
        'status': e['status'],
        'message': e['message'] ?? '',
        'updatedAt': e['updatedAt'],
      }).toList();
    } else {
      throw Exception('받은 요청 조회 실패');
    }
  }

  // Mate 보낸 요청 조회
  static Future<List<Map<String, dynamic>>> fetchSentRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final response = await http.get(
      Uri.parse('$baseUrl/api/mate/sent'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => {
        'requestId': e['requestId'],
        'receiverUsername': e['receiverUsername'] ?? '',
        'receiverNickname': e['receiverNickname'] ?? '',
        'status': e['status'],
        'message': e['message'] ?? '',
        'updatedAt': e['updatedAt'],
      }).toList();
    } else {
      throw Exception('보낸 요청 조회 실패');
    }
  }

  // Mate 요청 수락 or 거절
  static Future<void> respondMateRequest(int requestId, bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final endpoint = accepted ? '/api/mate/accept/$requestId' : '/api/mate/reject/$requestId';
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('응답 실패');
    }
  }

  // Mate 신청 취소
  static Future<void> cancelMateRequest(int requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final response = await http.delete(
      Uri.parse('$baseUrl/api/mate/cancel/$requestId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("요청 취소 실패: ${response.statusCode}");
    }
  }

  // Mate 해제
  static Future<void> disconnectMate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.post(
      Uri.parse('$baseUrl/api/mate/disconnect'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Mate 해제 실패: ${response.body}');
    }
  }
}
