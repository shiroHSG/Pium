// models/child/child_api.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_flutter/models/baby_profile.dart';

class ChildApi {
  static const String baseUrl = 'https://pium.store';

  // 아이 정보 전체 조회
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
      print('[DEBUG] 응답 JSON: $responseBody');
      final List<dynamic> data = jsonDecode(responseBody);
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
  static Future<bool> updateMyChild(BabyProfile updatedChild, {String? imagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return false;

    final uri = Uri.parse('$baseUrl/api/child/${updatedChild.childId}');
    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // 👉 JSON 문자열 구성 (profileImgUrl은 서버에서 자동 처리)
    final childJson = updatedChild.toJson();
    childJson.remove('profileImgUrl'); // ⚠️ 서버에서 image로 처리하므로 삭제

    request.fields['childData'] = jsonEncode(childJson);

    // 👉 이미지 파일 전송
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('아이 수정 실패: ${response.statusCode} - ${response.body}');
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
  static Future<bool> addMyChild(BabyProfile newChild, {String? imagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return false;

    final uri = Uri.parse('$baseUrl/api/child');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    final childJson = newChild.toJson();
    childJson.remove('profileImgUrl'); // 신규 등록 시도 때도 서버에서 처리하도록 제거
    request.fields['childData'] = jsonEncode(childJson);

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

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
