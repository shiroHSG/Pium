import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/member.dart'; // Member 모델 import

class MemberService {
  final String baseUrl = 'http://localhost:8080/api/member'; // 백엔드 기본 URL

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['token']; // 토큰 값 추출하여 반환
    } else {
      print('로그인 실패: ${response.statusCode}');
      return null;
    }
  }

  Future<bool> signup(Member member) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(member.toJson()),
    );

    if (response.statusCode == 200) {
      return true; // 회원가입 성공
    } else {
      print('회원가입 실패: ${response.statusCode}');
      return false; // 회원가입 실패
    }
  }

  // 특정 ID의 멤버 정보 가져오기
  Future<Member?> getMemberById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return Member.fromJson(responseData);
    } else {
      print('멤버 정보 가져오기 실패 (ID: $id): ${response.statusCode}');
      return null;
    }
  }

  // 모든 멤버 정보 가져오기
  Future<List<Member>> getAllMembers() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((json) => Member.fromJson(json)).toList();
    } else {
      print('모든 멤버 정보 가져오기 실패: ${response.statusCode}');
      return [];
    }
  }

  // 멤버 정보 업데이트
  Future<bool> updateMember(Member member) async {
    final response = await http.post(
      Uri.parse('$baseUrl/edit'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(member.toJson()),
    );

    if (response.statusCode == 200) {
      return true; // 업데이트 성공
    } else {
      print('멤버 정보 업데이트 실패 (ID: ${member.id}): ${response.statusCode}');
      return false; // 업데이트 실패
    }
  }

  // 특정 ID의 멤버 삭제
  Future<bool> deleteMember(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete/$id'));

    if (response.statusCode == 204) {
      return true; // 삭제 성공 (No Content 응답)
    } else {
      print('멤버 삭제 실패 (ID: $id): ${response.statusCode}');
      return false; // 삭제 실패
    }
  }
}