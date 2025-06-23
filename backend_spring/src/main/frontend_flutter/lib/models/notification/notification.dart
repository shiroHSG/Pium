import 'package:eventsource/eventsource.dart';
import 'dart:convert';

EventSource? _eventSource;

const _baseUrl = 'http://10.0.2.2:8080';

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
        print('📦 알림 데이터: $data');
        // TODO: 리스트에 추가, 뱃지 업데이트 등 처리
      }
    });
  } catch (e) {
    print('❌ SSE 연결 실패: $e');
  }
}

void disposeEventSource() {
  _eventSource?.client.close();
  _eventSource = null;
}
