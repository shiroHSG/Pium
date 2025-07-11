import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../notification/notification.dart';

class AuthService {
  static const String baseUrl = 'https://pium.store'; // 하드코딩

  // 회원가입
  Future<String?> signUp(
    Map<String, dynamic> memberData, {
    http.MultipartFile? imageFile,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/member/register');
      final request = http.MultipartRequest('POST', uri);

      // JSON 문자열로 변환해서 필드에 담기
      request.fields['memberData'] = jsonEncode(memberData);

      // 이미지가 있으면 추가
      if (imageFile != null) {
        request.files.add(imageFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return null; // 성공 시 에러 메시지 없음
      } else {
        final decoded = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> errorData = jsonDecode(decoded);
        final rawMessage = errorData['message'] ?? '회원가입 실패';
        final cleanMessage = rawMessage.toString().replaceFirst(
          '회원가입 실패: ',
          '',
        );
        return cleanMessage;
      }
    } catch (e) {
      print('회원가입 오류: $e');
      return '네트워크 오류';
    }
  }

  // 로그인
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/member/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email.trim(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String accessToken = data['accessToken'];
        final String refreshToken = data['refreshToken'];

        final dynamic rawId = data['memberId'] ?? data['id'];
        if (rawId == null || rawId is! int) {
          print('❗ 오류: memberId가 null이거나 int 타입이 아님 → $rawId');
          return false;
        }

        final int memberId = (rawId as num).toInt(); // int 또는 double 대응

        final prefs = await SharedPreferences.getInstance();
        print('🟢 로그인 후 저장된 memberId: ${prefs.getInt("memberId")}');
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        await prefs.setInt('memberId', memberId);

        print("🔔 알림 구독 시작 전");
        // 🔔 알림 구독 시작
        await subscribeToNotifications(accessToken); // <- 여기에 추가!
        print("🔔 알림 구독 완료");

        print("저장된 accessToken: $accessToken");
        print("저장된 refreshToken: $refreshToken");
        print("저장된 memberId: $memberId");
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

  // AccessToken 재발급
  Future<bool> reissueAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      print('리프레시 토큰 없음');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/member/reissue'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String newAccessToken = data['accessToken'];
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

  // 회원 정보 수정
  Future<bool> updateMemberInfo(
    Map<String, dynamic> memberData, {
    http.MultipartFile? imageFile,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/member');
      final request = http.MultipartRequest('PATCH', uri);

      request.fields['memberData'] = jsonEncode(memberData);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      request.headers['Authorization'] = 'Bearer $token';

      if (imageFile != null) {
        request.files.add(imageFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('✅ 회원 정보 수정 성공');
        return true;
      } else {
        print('❌ 수정 실패: ${response.statusCode}');
        print('본문: ${response.body}');
        return false;
      }
    } catch (e) {
      print('회원 정보 수정 오류: $e');
      return false;
    }
  }

// 로그아웃
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      print('로그아웃 시도 - accessToken: $accessToken');

      // 토큰이 없더라도 로컬 정보 삭제하고 로그아웃 처리
      if (accessToken == null) {
        print('accessToken 없음 - 토큰 삭제 후 로그아웃 처리');
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        await prefs.remove('memberId');
        disposeEventSource();
        return true;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/member/logout'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('로그아웃 API 응답: ${response.statusCode}, ${response.body}');

      // 로그아웃 성공 또는 토큰 만료(401) 모두 토큰 삭제 및 로그아웃 처리
      if (response.statusCode == 200 || response.statusCode == 401) {
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        await prefs.remove('memberId');
        disposeEventSource();
        print('로그아웃 완료');
        return true;
      } else {
        print('예외 응답 상태 코드: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('로그아웃 오류: $e');
      return false;
    }
  }


  // 내 정보 조회
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
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print('$data');
        return data;
      } else {
        print('회원 정보 조회 실패: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('회원 정보 조회 에러: $e');
      return null;
    }
  }

  // 회원 탈퇴
  Future<bool> deleteMember() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        print('회원 탈퇴 실패: 토큰 없음');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/member'),
        headers: <String, String>{
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

  // 닉네임 중복 확인
  Future<String?> checkNicknameDuplicate(String nickname) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/member/checkNickName?nickName=$nickname'));

      if (response.statusCode == 200) {
        return null; // 사용 가능
      } else if (response.statusCode == 409) {
        final data = jsonDecode(response.body);
        return data['message']; // 이미 사용 중
      } else {
        return '서버 오류가 발생했습니다.';
      }
    } catch (e) {
      return '네트워크 오류가 발생했습니다.';
    }
  }
}
