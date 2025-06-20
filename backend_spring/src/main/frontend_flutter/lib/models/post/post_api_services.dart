import 'dart:convert';
import 'package:frontend_flutter/models/post/post_request.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'post_response.dart';

class PostApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/posts';

  static Future<List<PostResponse>> fetchPosts(String category, {
    String? type,
    String? keyword,
    String? sort,
  }) async {
    final Uri uri = Uri.parse('$baseUrl').replace(queryParameters: {
      'category': category,
      if (type != null) 'type': type,
      if (keyword != null) 'keyword': keyword,
      if (sort != null) 'sort': sort,
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception('로그인 토큰이 없습니다. 로그인 해주세요.');
    }

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('게시글 조회 성공 200');
      List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => PostResponse.fromJson(e)).toList();
    } else {
      throw Exception('게시글 로드 실패: ${response.statusCode} ${response.body}');
    }
  }

  // PostRequest 객체를 매개변수로 받도록 수정하고, writer는 제거
  static Future<void> createPost({
    required PostRequest postRequest,
    http.MultipartFile? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception('로그인 토큰이 없습니다.');
    }

    final uri = Uri.parse('http://10.0.2.2:8080/api/posts');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['postData'] = jsonEncode(postRequest.toJson());

    if (imageFile != null) {
      request.files.add(imageFile);
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      print('✅ 게시글 생성 성공');
    } else {
      final res = await http.Response.fromStream(response);
      print('❌ 게시글 생성 실패: ${response.statusCode}, ${res.body}');
      throw Exception('게시글 생성 실패: ${response.statusCode}');
    }
  }
}
