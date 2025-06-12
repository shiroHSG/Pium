// models/child/child_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_flutter/models/baby_profile.dart';

class ChildApi {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // ✅ 아이 정보 전체 조회 (리스트 형태)
  static Future<List<BabyProfile>> fetchMyChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/api/child'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => BabyProfile.fromJson(e)).toList();
    } else {
      print('아이 정보 조회 실패: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  // 아이 정보 수정
  static Future<bool> updateMyChild(BabyProfile updatedChild) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return false;

    final response = await http.patch(
      Uri.parse('$baseUrl/api/child'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedChild.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('아이 정보 수정 실패: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // 아이 추가
  static Future<bool> addMyChild(BabyProfile newChild) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/api/child'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(newChild.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('아이 추가 실패: ${response.statusCode} - ${response.body}');
      return false;
    }
  }
}
