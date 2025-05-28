import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

late StompClient stompClient;

void main() {
  stompClient = StompClient(
    config: StompConfig(
      url: 'ws://localhost:8080/ws/chat',
      onConnect: onConnect,
      onWebSocketError: (error) => print('WebSocket error: \$error'),
    ),
  );

  stompClient.activate();
}

void onConnect(StompFrame frame) {
  print('✅ STOMP 연결됨');

  // /pub/echo → 응답이 /sub/echo로
  stompClient.subscribe(
    destination: '/sub/echo',
    callback: (frame) => print('✅ echo 응답: ${frame.body}'),
  );

  stompClient.send(
    destination: '/pub/echo',
    body: 'Flutter에서 보낸 메시지',
  );

// /pub/broadcast → 응답이 /sub/broadcast로
  stompClient.subscribe(
    destination: '/sub/broadcast',
    callback: (frame) => print('📣 broadcast 응답: ${frame.body}'),
  );

  stompClient.send(
    destination: '/pub/broadcast',
    body: '브로드캐스트 메시지',
  );
}
