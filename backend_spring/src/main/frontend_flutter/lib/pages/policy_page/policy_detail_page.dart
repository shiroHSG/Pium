import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/policy/PolicyResponse.dart';

class PolicyDetailPage extends StatelessWidget {
  final PolicyResponse policy;

  const PolicyDetailPage({
    Key? key,
    required this.policy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '정책 상세정보',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              policy.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppTheme.textPurple,
              ),
            ),
            const SizedBox(height: 16),
            // 등록일, 조회수
            Row(
              children: [
                Text(
                  '등록일: ${policy.createdAt.substring(0, 10)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Text(
                  '조회수: ${policy.viewCount}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 본문 내용
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  policy.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
