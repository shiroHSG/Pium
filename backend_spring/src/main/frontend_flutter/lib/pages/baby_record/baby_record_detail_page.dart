import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/diary/diary_api.dart';
import '../../screens/baby_record/baby_record_detail_page_ui.dart';

class BabyRecordDetailPage extends StatefulWidget {
  final int diaryId;

  const BabyRecordDetailPage({super.key, required this.diaryId});

  @override
  State<BabyRecordDetailPage> createState() => _BabyRecordDetailPageState();
}

class _BabyRecordDetailPageState extends State<BabyRecordDetailPage> {
  BabyRecordEntry? _entry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  Future<void> _loadDiary() async {
    final data = await DiaryApi.fetchDiaryById(widget.diaryId);
    setState(() {
      _entry = data;
      _isLoading = false;
    });
  }

  void _refreshEntry(BabyRecordEntry updated) {
    setState(() {
      _entry = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _entry == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String formattedDate =
    DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(_entry!.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('육아일지'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        // ✅ 삭제 버튼 제거됨
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BabyRecordDetailHeader(
              date: formattedDate,
              isPublic: _entry!.published,
            ),
            const SizedBox(height: 16),
            BabyRecordDetailTitleAndImage(
              title: _entry!.title,
              imageUrl: _entry!.imageUrl,
            ),
            const SizedBox(height: 24),
            BabyRecordDetailContent(
              publicContent:
              _entry!.publicContent ?? '공개 내용이 없습니다.',
              privateContent:
              _entry!.privateContent ?? '비공개 내용이 없습니다.',
            ),
            const SizedBox(height: 24),
            BabyRecordDetailPageUi(
              entry: _entry!,
              onEdited: _refreshEntry,
            ),
          ],
        ),
      ),
    );
  }
}
