import '../models/member.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemberService {
  final String baseUrl; // baseUrl을 클래스 변수로 관리

  MemberService({required this.baseUrl}); // 생성자에서 baseUrl을 받음

  Future<String?> login(String email, String password) async {
    try {
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
        return responseData['token'];
      } else {
        print('로그인 실패: 상태 코드 ${response.statusCode}, 응답 본문: ${response.body}');
        // 필요하다면 예외를 발생시킬 수 있음
        // throw Exception('로그인 실패');
        return null;
      }
    } catch (e) {
      print('로그인 요청 중 오류 발생: $e');
      // 필요하다면 예외를 발생시킬 수 있음
      // throw Exception('로그인 요청 중 오류 발생: $e');
      return null;
    }
  }

  Future<bool> signup(Member member) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(member.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('회원가입 실패: 상태 코드 ${response.statusCode}, 응답 본문: ${response.body}');
        return false;
      }
    } catch (e) {
      print('회원가입 요청 중 오류 발생: $e');
      return false;
    }
  }

  Future<Member?> getMemberById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Member.fromJson(responseData);
      } else {
        print('멤버 정보 가져오기 실패 (ID: $id): 상태 코드 ${response.statusCode}, 응답 본문: ${response.body}');
        return null;
      }
    } catch (e) {
      print('멤버 정보 가져오기 요청 중 오류 발생 (ID: $id): $e');
      return null;
    }
  }

  Future<bool> updateMember(Member member) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/edit'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(member.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('멤버 정보 업데이트 실패 (ID: ${member.id}): 상태 코드 ${response.statusCode}, 응답 본문: ${response.body}');
        return false;
      }
    } catch (e) {
      print('멤버 정보 업데이트 요청 중 오류 발생 (ID: ${member.id}): $e');
      return false;
    }
  }

  Future<bool> deleteMember(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/delete/$id'));

      if (response.statusCode == 204) {
        return true;
      } else {
        print('멤버 삭제 실패 (ID: $id): 상태 코드 ${response.statusCode}, 응답 본문: ${response.body}');
        return false;
      }
    } catch (e) {
      print('멤버 삭제 요청 중 오류 발생 (ID: $id): $e');
      return false;
    }
  }
}