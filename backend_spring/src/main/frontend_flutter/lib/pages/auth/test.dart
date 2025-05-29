import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '입력 예제',
      home: InputExample(),
    );
  }
}

class InputExample extends StatefulWidget {
  @override
  _InputExampleState createState() => _InputExampleState();
}

class _InputExampleState extends State<InputExample> {
  final TextEditingController _controller = TextEditingController();
  String _displayText = '';

  void _submitText() {
    setState(() {
      _displayText = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 입력 예제')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '이름을 입력하세요',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitText,
              child: const Text('입력 완료'),
            ),
            const SizedBox(height: 24),
            Text(
              '입력한 이름: $_displayText',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
