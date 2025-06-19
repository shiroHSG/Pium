import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<String?> signUp(Map<String, dynamic> memberData, {http.MultipartFile? imageFile}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/member/register');
      final request = http.MultipartRequest('POST', uri);
      request.fields['memberData'] = jsonEncode(memberData);
      if (imageFile != null) {
        request.files.add(imageFile);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return null;
      } else {
        final decoded = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> errorData = jsonDecode(decoded);
        final rawMessage = errorData['message'] ?? '회원가입 실패';
        return rawMessage.toString().replaceFirst('회원가입 실패: ', '');
      }
    } catch (e) {
      print('회원가입 오류: $e');
      return '네트워크 오류';
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/member/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final memberId = data['memberId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        await prefs.setInt('memberId', memberId);

        print("저장된 accessToken: $accessToken");
        print("저장된 refreshToken: $refreshToken");
        return true;
      } else {
        print('응답 상태 코드: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        return false;
      }
    } catch (e) {
      print('로그인 오류: $e');
      return false;
    }
  }

  Future<bool> reissueAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      print('리프레시 토큰 없음');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/member/reissue'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];
        await prefs.setString('accessToken', newAccessToken);
        print("새 accessToken 저장: $newAccessToken");
        return true;
      } else {
        print('토큰 재발급 실패: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('토큰 재발급 오류: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        print('로그아웃 실패: 토큰 없음');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/member/logout'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        await prefs.remove('memberId');
        print('로그아웃 완료');
        return true;
      } else {
        print('응답 상태 코드: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        return false;
      }
    } catch (e) {
      print('로그아웃 오류: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchMemberInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/member'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('회원 정보 조회 실패: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('회원 정보 조회 에러: $e');
      return null;
    }
  }

  Future<bool> deleteMember() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        print('회원 탈퇴 실패: 토큰 없음');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/member'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        await prefs.remove('memberId');
        print('회원 탈퇴 완료');
        return true;
      } else {
        print('회원 탈퇴 실패: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('회원 탈퇴 에러: $e');
      return false;
    }
  }
}
