import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_response.dart';

class PostApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<List<PostResponse>> fetchPosts(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/posts?category=$category'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => PostResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  static Future<PostResponse> createPost({
    required String title,
    required String content,
    required String category,
    String? postImg,
    required String writer,
  }) async {
    final url = Uri.parse('$baseUrl/posts');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'content': content,
        'category': category,
        'postImg': postImg,
        'writer': writer,
      }),
    );

    if (response.statusCode == 201) {
      return PostResponse.fromJson(jsonDecode(response.body));
    } else {
      // 서버에서 에러 메시지를 포함할 경우 파싱하여 보여줄 수 있습니다.
      throw Exception('Failed to create post: ${response.statusCode} ${response.body}');
    }
  }
}