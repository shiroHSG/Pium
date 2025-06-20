import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sharing_response.dart';
import 'sharing_request.dart';

class SharingApiServices {
  static const String baseUrl = 'http://10.0.2.2:8080/api/shares';

  static Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  /// 전체 목록 조회
  static Future<List<SharingResponse>> fetchSharingList({String? token}) async {
    final res = await http.get(Uri.parse(baseUrl), headers: _headers(token));
    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      return body.map((e) => SharingResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load sharing list');
    }
  }

  /// 게시글 상세 조회
  static Future<SharingResponse> fetchSharingDetail(int id, {String? token}) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'), headers: _headers(token));
    if (res.statusCode == 200) {
      return SharingResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to load sharing detail');
    }
  }

  /// 게시글 작성
  static Future<bool> createSharing({
    required SharingRequest request,
    required String token,
  }) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: _headers(token),
      body: jsonEncode(request.toJson()),
    );
    return res.statusCode == 201;
  }

  /// 게시글 수정
  static Future<bool> updateSharing({
    required int id,
    required SharingRequest request,
    required String token,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: _headers(token),
      body: jsonEncode(request.toJson()),
    );
    return res.statusCode == 200;
  }

  /// 게시글 삭제
  static Future<bool> deleteSharing(int id, String token) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: _headers(token),
    );
    return res.statusCode == 204;
  }

  /// 좋아요 (토글)
  static Future<bool> likeSharing(int id, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$id/like'),
      headers: _headers(token),
    );
    return res.statusCode == 200;
  }

  /// 좋아요 수 반환
  static Future<int> fetchLikeCount(int id, {String? token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/$id/like'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['likeCount'] as int;
    } else {
      throw Exception('Failed to fetch like count');
    }
  }
}
