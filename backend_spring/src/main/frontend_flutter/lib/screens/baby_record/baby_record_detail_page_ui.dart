import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class BabyRecordDetailHeader extends StatelessWidget {
  final String date;
  final bool isPublic;

  const BabyRecordDetailHeader({super.key, required this.date, required this.isPublic});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        Text(
          isPublic ? '공개' : '비공개',
          style: TextStyle(
            fontSize: 16,
            color: isPublic ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class BabyRecordDetailTitleAndImage extends StatelessWidget {
  final String title;

  const BabyRecordDetailTitleAndImage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
              '이미지',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

class BabyRecordDetailContent extends StatelessWidget {
  final String publicContent;
  final String privateContent;

  const BabyRecordDetailContent({
    super.key,
    required this.publicContent,
    required this.privateContent,
  });

  Widget _buildContentBlock(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildContentBlock('내용', publicContent),
        const SizedBox(height: 16),
        _buildContentBlock('내 아이 일기', privateContent),
      ],
    );
  }
}

class BabyRecordDetailActions extends StatelessWidget {
  const BabyRecordDetailActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
