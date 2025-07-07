import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_flutter/models/calendar/schedule.dart';

class CalendarApi {
  // 일정 등록
  static Future<Schedule> postSchedule(Schedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/calendar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(schedule.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return Schedule.fromJson(data);
    } else {
      throw Exception('일정 추가 실패: ${response.body}');
    }
  }

  // 일정 전체 조회 (본인 + Mate 포함)
  static Future<List<Schedule>> fetchSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/calendar'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Schedule.fromJson(json)).toList();
    } else {
      throw Exception('일정 목록 불러오기 실패: ${response.body}');
    }
  }

  // 일정 수정
  static Future<void> updateSchedule(Schedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (schedule.id == null) {
      throw Exception('수정할 일정의 ID가 없습니다.');
    }

    final response = await http.patch(
      Uri.parse('http://10.0.2.2:8080/api/calendar/${schedule.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(schedule.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('일정 수정 실패: ${response.body}');
    }
  }

  // 일정 삭제
  static Future<void> deleteSchedule(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8080/api/calendar/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('일정 삭제 실패: ${response.body}');
    }
  }
}
