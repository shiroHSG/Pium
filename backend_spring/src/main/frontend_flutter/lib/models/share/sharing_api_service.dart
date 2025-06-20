import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharingApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/shares';

  static Future<List<SharingItem>> fetchAllShares() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken'); // 로그인 후 저장된 토큰

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => SharingItem.fromJson(json)).toList();
    } else {
      throw Exception('나눔글 목록 불러오기 실패: ${response.statusCode}');
    }
  }
}
