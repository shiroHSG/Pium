import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharingApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/shares';

  // 나눔글 목록 가져오기
  static Future<List<SharingItem>> fetchAllShares() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception('로그인 정보가 없습니다. 다시 로그인해 주세요.');
    }
    print('💡 토큰: $token');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(
          utf8.decode(response.bodyBytes));
      return jsonList.map((json) => SharingItem.fromJson(json)).toList();
    } else {
      throw Exception('나눔글 목록 불러오기 실패: ${response.statusCode}');
    }
  }

  // 나눔글 등록
  static Future<void> createShare({
    required String title,
    required String content,
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) throw Exception('로그인 정보가 없습니다.');

    final uri = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['shareData'] = jsonEncode({
      'title': title,
      'content': content,
    });

    if (imageFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('글 작성 실패: ${response.body}');
    }
  }
}
