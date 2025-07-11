import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharingApiService {
  static const String _host = '10.0.2.2:8080';
  static const String _basePath = '/api/shares';

  // 🔍 나눔글 검색 (제목/작성자/주소/카테고리)
  static Future<List<SharingItem>> searchShares(String keyword, String category) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception('로그인 정보가 없습니다. 다시 로그인해 주세요.');
    }

    // category == '전체'면 파라미터 제외!
    final queryParams = {
      'keyword': keyword,
      if (category != '전체') 'category': category,
    };

    final uri = Uri.http(_host, '$_basePath/search', queryParams);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => SharingItem.fromJson(json)).toList();
    } else {
      throw Exception('검색 실패: ${response.statusCode}');
    }
  }

  // 나눔글 전체 목록 가져오기
  static Future<List<SharingItem>> fetchAllShares() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception('로그인 정보가 없습니다. 다시 로그인해 주세요.');
    }
    print('💡 토큰: $token');

    final uri = Uri.http(_host, _basePath);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => SharingItem.fromJson(json)).toList();
    } else {
      throw Exception('나눔글 목록 불러오기 실패: ${response.statusCode}');
    }
  }

  // ⭐️ 내가 쓴 나눔글 목록 (페이징)
  static Future<List<SharingItem>> fetchMyShares({int page = 0, int size = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) throw Exception('로그인 정보가 없습니다.');

    final uri = Uri.http(_host, '$_basePath/mine', {'page': '$page', 'size': '$size'});

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('[DEBUG] 내가 쓴 나눔글 응답: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> content = body['content'] ?? [];
      return content.map((e) => SharingItem.fromJson(e)).toList();
    } else {
      throw Exception('내가 쓴 나눔글 목록 불러오기 실패: ${response.statusCode}');
    }
  }

  // ⭐️ 좋아요 누른 나눔글 목록 (페이징)
  static Future<List<SharingItem>> fetchLikedShares({int page = 0, int size = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) throw Exception('로그인 정보가 없습니다.');

    final uri = Uri.http(_host, '$_basePath/liked-list', {'page': '$page', 'size': '$size'});

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('[DEBUG] 내가 좋아요 한 글 응답: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> content = body['content'] ?? [];
      return content.map((e) => SharingItem.fromJson(e)).toList();
    } else {
      throw Exception('좋아요 누른 나눔글 목록 불러오기 실패: ${response.statusCode}');
    }
  }

  // 나눔글 등록
  static Future<void> createShare({
    required String title,
    required String content,
    required String category,
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) throw Exception('로그인 정보가 없습니다.');

    final uri = Uri.http(_host, _basePath);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['shareData'] = jsonEncode({
      'title': title,
      'content': content,
      'category': category,
    });

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('글 작성 실패: ${response.body}');
    }
  }

  // 좋아요 수 불러오기
  static Future<int> fetchLikes(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final uri = Uri.http(_host, '$_basePath/$postId/like');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('좋아요 수 불러오기 실패');
    }
  }

  // 좋아요 토글
  static Future<bool> toggleLike(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final uri = Uri.http(_host, '$_basePath/$postId/like');

    final response = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body == 'liked';
    } else {
      throw Exception('좋아요 토글 실패');
    }
  }

  // 게시글 상세 조회 (조회수)
  static Future<SharingItem> fetchShareDetail(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final uri = Uri.http(_host, '$_basePath/$postId');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return SharingItem.fromJson(jsonData);
    } else {
      throw Exception('게시글 상세 조회 실패: ${response.statusCode}');
    }
  }

  // 글 수정 (PATCH)
  static Future<void> updateShare({
    required int id,
    required String title,
    required String content,
    required String category,
    File? imageFile, // null이면 이미지 삭제
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) throw Exception('로그인 정보가 없습니다.');

    final uri = Uri.http(_host, '$_basePath/$id');
    final request = http.MultipartRequest('PATCH', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['shareData'] = jsonEncode({
      'title': title,
      'content': content,
      'category': category,
    });

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('글 수정 실패: ${response.body}');
    }
  }

  // 글 삭제
  static Future<void> deleteShare(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) throw Exception('로그인 정보가 없습니다.');

    final uri = Uri.http(_host, '$_basePath/$id');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('글 삭제 실패: ${response.body}');
    }
  }
}
