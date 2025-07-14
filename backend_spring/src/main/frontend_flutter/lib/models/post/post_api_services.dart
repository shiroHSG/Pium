import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'post_request.dart';
import 'post_response.dart';
import 'post_comment.dart';

// 리스트 아이템용 DTO
class PostListItem {
  final int id;
  final String title;
  final DateTime createdAt;
  final String nickname;

  PostListItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.nickname,
  });

  factory PostListItem.fromJson(Map<String, dynamic> json) {
    List<dynamic>? dateArr = json['createdAt'];
    DateTime dt;
    if (dateArr is List && dateArr.length >= 3) {
      dt = DateTime(
        dateArr[0] ?? 2000,
        dateArr[1] ?? 1,
        dateArr[2] ?? 1,
        dateArr.length > 3 ? dateArr[3] ?? 0 : 0,
        dateArr.length > 4 ? dateArr[4] ?? 0 : 0,
        dateArr.length > 5 ? dateArr[5] ?? 0 : 0,
        dateArr.length > 6 ? (dateArr[6] ?? 0) ~/ 1000000 : 0,
      );
    } else {
      dt = DateTime(2000, 1, 1);
    }
    return PostListItem(
      id: json['id'] ?? json['postId'],
      title: json['title'] ?? '',
      createdAt: dt,
      nickname: json['nickname'] ?? '',
    );
  }
}

class PostApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/posts'; // API 전용
  static const String baseImageUrl = 'http://10.0.2.2:8080';       // 이미지 전용

  // ⭐️ 인기 게시글 3개 호출 (추가!)
  static Future<List<PostResponse>> fetchPopularPosts({int size = 3}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final uri = Uri.parse('$baseUrl/popular?size=$size');

    if (token == null) throw Exception('로그인 토큰이 없습니다. 로그인 해주세요.');

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responseBody);
      return body.map((e) => PostResponse.fromJson(e)).toList();
    } else {
      throw Exception('인기 게시글 로드 실패: ${response.statusCode} ${response.body}');
    }
  }

  // 게시글 목록 조회
  static Future<List<PostResponse>> fetchPosts(
      String? category, {
        String? type,
        String? keyword,
        String? sort,
      }) async {
    print(
        '[DEBUG] API 요청: category=$category, type=$type, keyword=$keyword, sort=$sort');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    Uri uri;

    if (type != null && type.isNotEmpty && keyword != null && keyword.isNotEmpty) {
      uri = Uri.parse('$baseUrl/search').replace(
        queryParameters: {
          'type': type,
          'keyword': keyword,
        },
      );
    } else {
      final Map<String, String> queryParameters = {};
      if (category != null && category.isNotEmpty) {
        queryParameters['category'] = category;
      }
      if (sort != null) queryParameters['sort'] = sort;

      uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);
    }

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

  // ⭐️ 내가 쓴 게시글 목록 (페이징)
  static Future<List<PostListItem>> fetchMyPosts({int page = 0, int size = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final uri = Uri.parse('$baseUrl/mine?page=$page&size=$size');

    if (token == null) throw Exception('로그인 토큰이 없습니다. 로그인 해주세요.');

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    print('[DEBUG] 내가 쓴 글 목록 응답: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> body = jsonDecode(decoded);
      final List<dynamic> content = body['content'] ?? [];
      return content.map((e) => PostListItem.fromJson(e)).toList();
    } else {
      throw Exception('내가 쓴 글 목록 로드 실패: ${response.statusCode} ${response.body}');
    }
  }

  // ⭐️ 좋아요 누른 게시글 목록 (페이징)
  static Future<List<PostListItem>> fetchLikedPosts({int page = 0, int size = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final uri = Uri.parse('$baseUrl/liked-list?page=$page&size=$size');

    if (token == null) throw Exception('로그인 토큰이 없습니다. 로그인 해주세요.');

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> body = jsonDecode(decoded);
      final List<dynamic> content = body['content'] ?? [];
      return content.map((e) => PostListItem.fromJson(e)).toList();
    } else {
      throw Exception('좋아요 누른 글 목록 로드 실패: ${response.statusCode} ${response.body}');
    }
  }

  // 게시글 등록 (멀티파트)
  static Future<void> createPostMultipart({
    required String title,
    required String content,
    required String category,
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse(baseUrl);

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    final postData = jsonEncode({
      'title': title,
      'content': content,
      'category': category,
    });
    request.fields['postData'] = postData;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('게시글 등록 성공: ${response.body}');
    } else {
      print('게시글 등록 실패: ${response.statusCode} ${response.body}');
      throw Exception('게시글 작성 실패');
    }
  }

  // 게시글 수정
  static Future<void> updatePostMultipart({
    required int postId,
    required String title,
    required String content,
    required String category,
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$baseUrl/$postId');

    final request = http.MultipartRequest('PATCH', url);
    request.headers['Authorization'] = 'Bearer $token';

    final postData = jsonEncode({
      'title': title,
      'content': content,
      'category': category,
    });
    request.fields['postData'] = postData;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('게시글 수정 성공: ${response.body}');
    } else {
      print('게시글 수정 실패: ${response.statusCode} ${response.body}');
      throw Exception('게시글 수정 실패');
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

  // 게시글 상세 조회
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
      final decodedBody = utf8.decode(response.bodyBytes); // 디코딩 적용
      final jsonMap = json.decode(decodedBody); // 디코딩된 body 사용
      return PostResponse.fromJson(jsonMap);
    } else {
      throw Exception('게시글 상세 조회 실패');
    }
  }

  // 좋아요 토글
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
      return true;
    } else {
      print('좋아요 실패: ${response.statusCode} ${response.body}');
      return false;
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
    return response.statusCode == 200 || response.statusCode == 201;
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
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> list = json.decode(decoded);
      return list.map((json) => Comment.fromJson(json)).toList();
    } else {
    throw Exception('댓글 목록 조회 실패');
    }
  }
}
