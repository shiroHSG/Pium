import 'dart:convert';
import 'package:frontend_flutter/models/post/post_request.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'post_response.dart';
import 'package:frontend_flutter/models/post/post_comment.dart';

class PostApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/posts';

  // 게시글 목록 조회
  static Future<List<PostResponse>> fetchPosts(
      String? category, {
        String? type,
        String? keyword,
        String? sort,
      }) async {
    print('[DEBUG] API 요청: category=$category, type=$type, keyword=$keyword, sort=$sort');

    final Map<String, String> queryParameters = {};
    if (category != null && category.isNotEmpty) {
      queryParameters['category'] = category;
    }
    if (type != null) queryParameters['type'] = type;
    if (keyword != null) queryParameters['keyword'] = keyword;
    if (sort != null) queryParameters['sort'] = sort;

    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);

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
      final responseBody = utf8.decode(response.bodyBytes);
      print('게시글 조회 성공 200: $responseBody');
      List<dynamic> body = jsonDecode(responseBody);
      return body.map((e) => PostResponse.fromJson(e)).toList();
    } else {
      print('게시글 로드 실패: ${response.statusCode} ${response.body}');
      throw Exception('게시글 로드 실패: ${response.statusCode} ${response.body}');
    }
  }

  // 게시글 작성
  static Future<PostResponse> createPost({
    required PostRequest postRequest,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
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
      body: jsonEncode(postRequest.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("PostApiServices 게시글 작성 성공");
      return PostResponse.fromJson(jsonDecode(response.body));
    } else {
      print('PostApiServices 게시글 작성 실패: ${response.statusCode} ${response.body}');
      throw Exception('PostApiServices 게시글 작성에 실패했습니다: ${response.statusCode} ${response.body}');
    }
  }

  // 좋아요 토글 함수
  static Future<bool> toggleLike(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = '$baseUrl/$postId/like';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      // 서버에서 isLiked, likeCount 등을 내려주면 여기서 반환값을 파싱해서 전달할 수도 있음
      return true;
    } else {
      print('좋아요 실패: ${response.statusCode} ${response.body}');
      return false;
    }
  }

  // 게시글 상세 재조회 함수 (isLiked, likeCount 갱신 목적)
  static Future<PostResponse> fetchPostDetail(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = '$baseUrl/$postId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      return PostResponse.fromJson(jsonMap);
    } else {
      throw Exception('게시글 상세 조회 실패');
    }
  }

  // 댓글 등록
  static Future<bool> addComment(int postId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = '$baseUrl/$postId/comments';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('댓글 등록 실패: ${response.statusCode} ${response.body}');
      return false;
    }
  }

  // 댓글 목록 조회
  static Future<List<Comment>> fetchComments(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = '$baseUrl/$postId/comments';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(response.body);
      return list.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('댓글 목록 조회 실패');
    }
  }

  // 게시글 삭제
  static Future<bool> deletePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = '$baseUrl/$postId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // 게시글 수정
  static Future<bool> updatePost(
      int postId, {
    required String title, required String content, required String category, String? imgUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = '$baseUrl/$postId';
    final body = jsonEncode({
      'title': title,
      'content': content,
      'category': category,
      'imgUrl': imgUrl ?? '',
    });
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    return response.statusCode == 200;
  }
}
