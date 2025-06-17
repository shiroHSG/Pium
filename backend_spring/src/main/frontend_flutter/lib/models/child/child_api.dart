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
      final responseBody = utf8.decode(response.bodyBytes);
      print('[DEBUG] 응답 JSON: ${utf8.decode(response.bodyBytes)}');
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => BabyProfile.fromJson(e)).toList();
    } else {
      print('아이 정보 조회 실패: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  // 아이 단건 조회
  static Future<BabyProfile?> fetchChildById(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/child/$childId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return BabyProfile.fromJson(data);
    } else {
      print('아이 단건 조회 실패: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  // 아이 정보 수정
  static Future<bool> updateMyChild(BabyProfile updatedChild) async {
    final url = '$baseUrl/api/child/${updatedChild.childId}';
    print('[PATCH] URL: $url');
    print('[BODY] ${jsonEncode(updatedChild.toJson())}');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null || updatedChild.childId == null) return false;

    final response = await http.patch(
      Uri.parse('$baseUrl/api/child/${updatedChild.childId}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8', // ✅ charset 명시
      },
      body: utf8.encode(jsonEncode(updatedChild.toJson())), // ✅ UTF-8 인코딩
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('아이 정보 수정 실패: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // 아이 삭제
  static Future<bool> deleteChild(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/api/child/$childId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('아이 삭제 실패: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // 아이 추가
  static Future<bool> addMyChild(BabyProfile newChild) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return false;

    final uri = Uri.parse('$baseUrl/api/child');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // ✅ childData 라는 키로 JSON 문자열 전달
    final jsonBody = jsonEncode(newChild.toJson());
    request.fields['childData'] = jsonBody;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('아이 추가 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('네트워크 오류: $e');
      return false;
    }
  }

}
