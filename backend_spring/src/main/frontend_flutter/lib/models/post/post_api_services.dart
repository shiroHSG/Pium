import 'dart:convert';
import 'package:frontend_flutter/models/post/post_request.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'post_response.dart';

class PostApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/posts';

  static Future<List<PostResponse>> fetchPosts(
      String category, {
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
    final token = prefs.getString('token');

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
  static Future<PostResponse> createPost({
    required PostRequest postRequest,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("저장된 토큰: $token");

    if (token == null) {
      throw Exception('로그인 토큰이 없습니다. 로그인 해주세요.');
    }

    final url = Uri.parse('$baseUrl');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      // PostRequest 객체의 toJson() 메서드를 사용하여 JSON으로 변환
      body: jsonEncode(postRequest.toJson()),
    );

    // 201: 생성 성공(새로운 것을 성공적으로 생성), 200: 일반 요청 성공(요청을 설공적으로 처리)
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("PostApiServices 게시글 작성 성공");
      return PostResponse.fromJson(jsonDecode(response.body));
    } else {
      print('PostApiServices 게시글 작성 실패: ${response.statusCode} ${response.body}');
      throw Exception('PostApiServices 게시글 작성에 실패했습니다: ${response.statusCode} ${response.body}');
    }
  }
}