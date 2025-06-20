import 'package:flutter/material.dart';

// (미구현) 상세 페이지 필요 시, 아래 예시처럼 시작
class SharingDetailPage extends StatelessWidget {
  final int sharingId;
  final String? token;

  const SharingDetailPage({Key? key, required this.sharingId, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 상세 조회 fetch, UI 등 구현
    return Scaffold(
      appBar: AppBar(title: const Text('나눔/품앗이 상세')),
      body: const Center(child: Text('상세 페이지 구현 예정')),
    );
  }
}
