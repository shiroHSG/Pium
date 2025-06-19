import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';

late StompClient stompClient;


void connectStomp(String token, int myId, Function(int) onUnreadCount) {
  stompClient = StompClient(
    config: StompConfig.SockJS(
      url: 'http://10.0.2.2:8080/ws/chat?token=$token',
      onConnect: (StompFrame frame) {
        print('✅ WebSocket 연결됨');

        // unread-count 전용 구독
        stompClient.subscribe(
          destination: '/sub/member/$myId/unread-count',
          callback: (StompFrame frame) {
            print('📥 받은 WebSocket 메시지: ${frame.body}');
            final int count = int.parse(frame.body!);
            onUnreadCount(count);
          },
        );
      },
      onWebSocketError: (error) {
        print('❌ WebSocket 오류: $error');
      },
    ),
  );

  stompClient.activate();
}

void subscribeSummary(int myId, Function(dynamic) onSummary) {
  print("subscribeSummary 구독");
  // summary 전용 구독
  stompClient.subscribe(
    destination: '/sub/member/$myId/summary',
    callback: (StompFrame frame) {
      final data = jsonDecode(frame.body!);
      onSummary(data);
    },
  );
}

void subscribeChatRoomMessages(int chatRoomId, Function(dynamic) onMessage) {
  stompClient.subscribe(
    destination: '/sub/chatroom/$chatRoomId',
    callback: (StompFrame frame) {
      final data = jsonDecode(frame.body!);
      print('📥 채팅 메시지 수신: $data');
      onMessage(data);
    },
  );
}