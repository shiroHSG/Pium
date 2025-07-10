import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryApi {
  static const String baseUrl = 'https://pium.store'; // 실제 서버 주소

  // ✅ 육아 일지 리스트 조회 (childId 기준)
  static Future<List<BabyRecordEntry>> fetchDiariesByChildId(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return [];

    final uri = Uri.parse('$baseUrl/api/diaries?childId=$childId');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final list = decoded is List ? decoded : decoded['data'];

      if (list is List) {
        return list.map((e) => BabyRecordEntry.fromJson(e)).toList();
      } else {
        print('[ERROR] Invalid response format: $decoded');
        return [];
      }
    } else {
      print('[ERROR] Failed to fetch diary list: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  // ✅ 육아 일지 단건 조회 (diaryId 기준)
  static Future<BabyRecordEntry> fetchDiaryById(int diaryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) throw Exception("Access token not found");

    final response = await http.get(
      Uri.parse('$baseUrl/api/diaries/$diaryId'), // ✅ 수정된 경로
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return BabyRecordEntry.fromJson(data);
    } else {
      throw Exception('Diary fetch 실패: ${response.statusCode}');
    }
  }

  // ✅ 육아 일지 저장
  static Future<bool> saveDiary(BabyRecordEntry entry, {File? image}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return false;

    final uri = Uri.parse('$baseUrl/api/diaries');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    final diaryData = jsonEncode({
      'childId': entry.childId,
      'title': entry.title,
      'publicContent': entry.publicContent,
      'content': entry.privateContent,
      'published': entry.published,
    });
    request.fields['diaryData'] = diaryData;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final error = await response.stream.bytesToString();
      try {
        final decoded = jsonDecode(error);
        print('[ERROR] Failed to save diary: ${response.statusCode} - ${decoded['message'] ?? error}');
      } catch (_) {
        print('[ERROR] Failed to save diary: ${response.statusCode} - $error');
      }
      return false;
    }
  }

  // ✅ 육아 일지 수정
  static Future<bool> updateDiary(BabyRecordEntry entry, File? image) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return false;

    if (entry.id == null) {
      print('[ERROR] Diary ID is null. Cannot update.');
      return false;
    }

    final uri = Uri.parse('$baseUrl/api/diaries/${entry.id}');
    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';

    final diaryDataMap = {
      'title': entry.title,
      'publicContent': entry.publicContent,
      'content': entry.privateContent,
      'published': entry.published,
    };

    // ✅ 이미지 삭제 의도 명시
    if (image == null && (entry.imageUrl == null || entry.imageUrl!.isEmpty)) {
      diaryDataMap['removeImage'] = true;
    }

    final diaryData = jsonEncode(diaryDataMap);
    request.fields['diaryData'] = diaryData;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = await response.stream.bytesToString();
      print('[ERROR] Failed to update diary: $error');
      return false;
    }
  }

  // ✅ 육아 일지 삭제
  static Future<bool> deleteDiary(int diaryId) async {
    print('[DEBUG] deleteDiary 호출됨: $diaryId'); // ✅ 호출 로그

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      print('[ERROR] Token 없음');
      return false;
    }

    final uri = Uri.parse('$baseUrl/api/diaries/$diaryId');
    print('[DEBUG] DELETE URI: $uri'); // ✅ 경로 로그

    final response = await http.delete(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    print('[DEBUG] Status Code: ${response.statusCode}'); // ✅ 응답 확인

    if (response.statusCode == 200) {
      print('[DEBUG] 삭제 성공');
      return true;
    } else {
      print('[ERROR] Failed to delete diary: ${response.statusCode} - ${response.body}');
      return false;
    }
  }
}
