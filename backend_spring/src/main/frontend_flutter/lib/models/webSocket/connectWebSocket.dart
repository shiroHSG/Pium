import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';

late StompClient stompClient;

void connectStomp(String token, String myId) {
  stompClient = StompClient(
    config: StompConfig.SockJS(
      url: 'http://10.0.2.2:8080/ws/chat?token=$token', // ✅ 서버 URL + 토큰
      onConnect: (StompFrame frame) {
        print('✅ WebSocket 연결 완료');

        // ✅ 요약 정보 구독
        stompClient.subscribe(
          destination: '/sub/member/$myId/summary',
          callback: (StompFrame frame) {
            final data = jsonDecode(frame.body!);
            print('📩 요약 정보 수신: $data');

            // ✅ TODO: 상태 업데이트 처리 함수 호출
            updateSidebarBadge(data);
            updateChatListItem(data);
          },
        );
      },
      onWebSocketError: (dynamic error) => print('❌ WebSocket 오류: $error'),
      stompConnectHeaders: {
        'Authorization': 'Bearer $token',
      },
    ),
  );

  stompClient.activate();
}
