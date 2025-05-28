import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:intl/intl.dart';

class BabyRecordDetailPage extends StatelessWidget {
  final BabyRecordEntry entry;

  const BabyRecordDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy년 MM월 dd일 HH시 mm분');
    final String formattedDate = formatter.format(entry.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('육아일지'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  entry.isPublic ? '공개' : '비공개',
                  style: TextStyle(
                    fontSize: 16,
                    color: entry.isPublic ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              entry.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPurple,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  '여기에 이미지가 표시될 예정입니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '내용',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                entry.publicContent,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '내 아이 일기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                entry.privateContent,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('수정 기능은 아직 구현되지 않았습니다.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('수정'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('삭제'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}