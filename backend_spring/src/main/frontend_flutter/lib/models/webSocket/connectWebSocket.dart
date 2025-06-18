import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';

late StompClient stompClient;

void connectStomp(String token, int myId) {
  stompClient = StompClient(
    config: StompConfig.SockJS(

      url: 'http://10.0.2.2:8080/ws/chat?token=$token',
      onConnect: (StompFrame frame) {
        print('✅ WebSocket 연결 완료');
        // ✅ 요약 구독 시작
        stompClient.subscribe(
          destination: '/sub/member/$myId/summary',
          callback: (StompFrame frame) {
            final data = jsonDecode(frame.body!);
            print('📩 요약 수신: $data');

            // 상태 반영 (임시 예시)
            updateSidebarBadge(data);
            updateChatListItem(data);
          },
        );
      },
      onWebSocketError: (error) {
        print('$token');
        print('❌ WebSocket 오류 발생: $error');
      },
    ),
  );

  stompClient.activate(); // 연결 실행
}

void updateSidebarBadge(dynamic data) {
  int unreadCount = data['unreadCount'];
  // TODO: 전체 뱃지 총합 상태에 반영 (setState, Provider, Riverpod 등 활용)
}

void updateChatListItem(dynamic data) {
  int chatRoomId = data['chatRoomId'];
  String lastMessage = data['lastMessage'];
  String lastSentAt = data['lastSentAt'];
  int unreadCount = data['unreadCount'];

  // TODO: 채팅방 목록 중 chatRoomId에 해당하는 항목을 찾아서 내용 갱신
}