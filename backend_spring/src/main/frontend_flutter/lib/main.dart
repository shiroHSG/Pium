import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestApiPage(),
    );
  }
}

class TestApiPage extends StatefulWidget {
  @override
  State<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  String _message = '응답 대기 중...';

  Future<void> fetchMessage() async {
    final uri = Uri.parse('http://10.0.2.2:8080/api/test'); // 안드로이드 에뮬레이터 기준
    // final uri = Uri.parse('http://내 ip4 주소:8080/api/test');  // 실제기기 기준

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonBody = json.decode(decodedBody);
        setState(() {
          _message = jsonBody['message'] ?? '응답 없음';
        });
      } else {
        setState(() {
          _message = '에러 발생: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '요청 실패: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter → Spring Boot')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchMessage,
              child: const Text('API 호출'),
            )
          ],
        ),
      ),
    );
  }
}
