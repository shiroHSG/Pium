import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_response.dart';

class PostApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/posts';

  static Future<List<PostResponse>> fetchPosts(
      String category, {
        String? type,
        String? keyword,
        String? sort,
      }) async {
    final Uri uri = Uri.parse('$baseUrl/posts').replace(queryParameters: {
      'category': category,
      if (type != null) 'type': type,
      if (keyword != null) 'keyword': keyword,
      if (sort != null) 'sort': sort,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => PostResponse.fromJson(e)).toList();
    } else {
      throw Exception('\nFailed to load posts');
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
      throw Exception('Failed to create post: ${response.statusCode} ${response.body}');
    }
  }
}