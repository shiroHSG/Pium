import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/models/policy/PolicyResponse.dart';

class PolicyService {
  static const String baseUrl = "http://10.0.2.2:8080/api/policies";

  /// 정책 리스트 조회 (정렬/페이지네이션)
  /// 반환: { content: List<PolicyResponse>, totalPages: int }
  static Future<Map<String, dynamic>> fetchPolicies({
    required int page,
    required int size,
    required String sortBy,
  }) async {
    final url = Uri.parse('$baseUrl?page=${page - 1}&size=$size&sortBy=$sortBy');
    final response = await http.get(url);

    print('----- [fetchPolicies] 응답 바디 -----');
    print(response.body);
    print('----- [fetchPolicies] statusCode: ${response.statusCode} -----');

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      print('[fetchPolicies] decode 결과 타입: ${data.runtimeType}');
      print('[fetchPolicies] decode 결과: $data');

      if (data is Map && data.containsKey('content')) {
        List<dynamic> content = data['content'];
        int totalPages = data['totalPages'] ?? 1;
        print('[fetchPolicies] content 리스트 길이: ${content.length}');
        return {
          'content': content.map((e) => PolicyResponse.fromJson(e)).toList(),
          'totalPages': totalPages,
        };
      } else if (data is List) {
        // 리스트로 바로 온다면 totalPages 1로 처리
        return {
          'content': data.map((e) => PolicyResponse.fromJson(e)).toList(),
          'totalPages': 1,
        };
      } else {
        throw Exception('정책 데이터 응답 구조가 맞지 않습니다.');
      }
    } else {
      throw Exception('정책 리스트를 불러올 수 없습니다');
    }
  }

  /// 정책 검색 (키워드 기반, 페이징)
  /// 반환: { content: List<PolicyResponse>, totalPages: int }
  static Future<Map<String, dynamic>> searchPolicies({
    required String keyword,
    required int page,
    required int size,
  }) async {
    final url = Uri.parse('$baseUrl/search?keyword=$keyword&page=${page - 1}&size=$size');
    final response = await http.get(url);

    print('----- [searchPolicies] 응답 바디 -----');
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print('[searchPolicies] decode 결과 타입: ${data.runtimeType}');
      print('[searchPolicies] decode 결과: $data');

      if (data is Map && data.containsKey('content')) {
        List<dynamic> content = data['content'];
        int totalPages = data['totalPages'] ?? 1;
        return {
          'content': content.map((e) => PolicyResponse.fromJson(e)).toList(),
          'totalPages': totalPages,
        };
      } else if (data is List) {
        // 리스트로 바로 온다면 totalPages 1로 처리
        return {
          'content': data.map((e) => PolicyResponse.fromJson(e)).toList(),
          'totalPages': 1,
        };
      } else {
        throw Exception('검색 결과 데이터 형식이 다릅니다');
      }
    } else {
      throw Exception('정책 검색 결과를 불러올 수 없습니다');
    }
  }

  /// 정책 상세조회 (id 기반)
  static Future<PolicyResponse> fetchPolicyDetail(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.get(url);

    print('----- [fetchPolicyDetail] 응답 바디 -----');
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return PolicyResponse.fromJson(data);
    } else {
      throw Exception('정책 상세 정보를 불러올 수 없습니다');
    }
  }
}
