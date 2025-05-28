import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class TestWebSocketPage extends StatefulWidget {
  const TestWebSocketPage({super.key});

  @override
  State<TestWebSocketPage> createState() => _TestWebSocketPageState();
}

class _TestWebSocketPageState extends State<TestWebSocketPage> {
  late StompClient stompClient;
  String _receivedMessage = '응답 대기 중...';

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws/chat', // Android 에뮬레이터 기준
        onConnect: _onConnect,
        onWebSocketError: (error) => print('WebSocket error: $error'),
      ),
    );

    stompClient.activate();
  }

  void _onConnect(StompFrame frame) {
    print('✅ WebSocket 연결 완료');

    // 수신 구독
    stompClient.subscribe(
      destination: '/sub/broadcast',
      callback: (frame) {
        setState(() {
          _receivedMessage = frame.body ?? '응답 없음';
        });
      },
    );
  }

  void _sendMessage() {
    stompClient.send(
      destination: '/pub/broadcast',
      body: 'Flutter에서 보낸 메시지입니다!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket 테스트')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_receivedMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('메시지 보내기'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    stompClient.deactivate();
    super.dispose();
  }
}
