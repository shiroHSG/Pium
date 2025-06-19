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


void updateChatListItem(dynamic data) {
  int chatRoomId = data['chatRoomId'];
  String lastMessage = data['lastMessage'];
  String lastSentAt = data['lastSentAt'];
  int unreadCount = data['unreadCount'];

  // TODO: 채팅방 목록 중 chatRoomId에 해당하는 항목을 찾아서 내용 갱신
}