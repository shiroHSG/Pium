import 'package:eventsource/eventsource.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 🔔 전역 알림 리스트
List<Map<String, dynamic>> notificationList = [];

/// 🔁 알림 수신 시 UI 갱신을 위한 콜백 함수
void Function()? onNotificationUpdate;

EventSource? _eventSource;

const _baseUrl = 'http://10.0.2.2:8080';

Future<void> fetchUnreadNotifications(String token) async {
  try {
    final url = Uri.parse('http://10.0.2.2:8080/api/notifications/unread');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      notificationList.clear(); // 기존 알림 제거
      for (var item in data) {
        notificationList.add({
          'category': mapTypeToCategory(item['type']),
          'icon': mapTypeToIcon(item['type']),
          'message': item['message'],
          'date': formatDate(item['createdAt']),
        });
      }

    } else {
      print('❌ 안 읽은 알림 조회 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ 안 읽은 알림 조회 중 오류: $e');
  }
}


Future<void> subscribeToNotifications(String token) async {
  try {
    final url = Uri.parse('$_baseUrl/api/notifications/subscribe');

    _eventSource = await EventSource.connect(
      url.toString(),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _eventSource?.listen((Event event) {
      print('📥 이벤트 수신: ${event.event} / ${event.data}');

      if (event.event == 'notification') {
        final data = jsonDecode(event.data!);

        final parsed = {
          'category': mapTypeToCategory(data['type']),
          'icon': mapTypeToIcon(data['type']),
          'message': data['message'],
          'date': formatDate(data['createdAt']), // 혹은 포맷팅
        };

        print('$parsed');

        notificationList.insert(0, parsed); // 최신 알림 위로 추가

        onNotificationUpdate?.call();

        print('📦 알림 데이터 추가됨 → 현재 수: ${notificationList.length}');
      }
    });
  } catch (e) {
    print('❌ SSE 연결 실패: $e');
  }
}

Future<void> markAllNotificationsAsRead(String token) async {
  final url = Uri.parse('$_baseUrl/api/notifications/mark-as-read');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    print('✅ 읽음 처리 완료');

    // 🔄 알림 리스트 비우고 UI 갱신
    notificationList.clear();
    onNotificationUpdate?.call();
  } else {
    print('❌ 읽음 처리 실패: ${response.statusCode}');
  }
}

String formatDate(dynamic rawDate) {
  if (rawDate is List && rawDate.length >= 6) {
    return "${rawDate[0]}.${rawDate[1].toString().padLeft(2, '0')}.${rawDate[2].toString().padLeft(2, '0')} "
        "${rawDate[3].toString().padLeft(2, '0')}:${rawDate[4].toString().padLeft(2, '0')}";
  } else {
    return "날짜 없음";
  }
}

void disposeEventSource() {
  _eventSource?.client.close();
  _eventSource = null;
}

String mapTypeToCategory(String type) {
  switch (type) {
    case 'COMMENT':
      return '커뮤니티';
    case 'MATE_REQUEST':
      return '메이트 요청';
    default:
      return '기타';
  }
}

IconData mapTypeToIcon(String type) {
  switch (type) {
    case 'COMMENT':
      return Icons.groups;
    case 'MATE_REQUEST':
      return Icons.chat;
    default:
      return Icons.notifications;
  }
}