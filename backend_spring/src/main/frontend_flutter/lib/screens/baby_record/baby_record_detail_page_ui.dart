import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import '../../models/diary/diary_api.dart';
import '../../pages/baby_record/edit_baby_record_page.dart';

class BabyRecordDetailHeader extends StatelessWidget {
  final String date;
  final bool isPublic;

  const BabyRecordDetailHeader({
    super.key,
    required this.date,
    required this.isPublic,
  });

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
  final String? imageUrl;

  const BabyRecordDetailTitleAndImage({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Android 에뮬레이터용 완전한 이미지 URL 생성
    final fullImageUrl = (imageUrl != null && imageUrl!.isNotEmpty)
        ? 'http://10.0.2.2:8080${imageUrl!.startsWith('/') ? imageUrl : '/${imageUrl!}'}'
        : null;

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
          constraints: const BoxConstraints(
            maxHeight: 300, // ✅ 최대 높이 제한
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: fullImageUrl != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fullImageUrl,
              fit: BoxFit.contain, // ✅ 이미지 비율 유지하며 최대한 채움
              errorBuilder: (_, __, ___) =>
              const Center(child: Text('이미지를 불러올 수 없습니다.')),
            ),
          )
              : const Center(child: Text('이미지 없음')),
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
        if (publicContent.trim().isNotEmpty) ...[
          _buildContentBlock('자유 게시판 공유 내용', publicContent),
          const SizedBox(height: 16),
        ],
        if (privateContent.trim().isNotEmpty)
          _buildContentBlock('내 아이 일기', privateContent),
      ],
    );
  }
}

class BabyRecordDetailPageUi extends StatelessWidget {
  final BabyRecordEntry entry;
  final void Function(BabyRecordEntry updated)? onEdited;

  const BabyRecordDetailPageUi({
    super.key,
    required this.entry,
    this.onEdited,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditBabyRecordPage(entry: entry),
              ),
            );

            if (result == true && context.mounted) {
              final updated = await DiaryApi.fetchDiaryById(entry.id!);
              onEdited?.call(updated);
              Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: Colors.white,
          ),
          child: const Text('수정'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            print('[DEBUG] 상세 하단 삭제 버튼 눌림');
            final success = await DiaryApi.deleteDiary(entry.id!);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("삭제가 완료되었습니다.")),
              );
              Navigator.pop(context, true); // 리스트 화면으로 돌아가기
            } else {
              print('[ERROR] 삭제 실패');
            }
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