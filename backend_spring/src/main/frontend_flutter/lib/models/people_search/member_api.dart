import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/models/people_search//member_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberApi {
  static const String baseUrl = 'http://10.0.2.2:8080/api/member';

  static Future<List<Member>> searchMembers(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$baseUrl/search?query=$query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedBody);
      return data.map((item) => Member.fromJson(item)).toList();
    } else {
      throw Exception('검색 실패: ${response.statusCode}');
    }
  }
}