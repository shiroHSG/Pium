import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import '../../screens/baby_record/baby_record_detail_page_ui.dart';

class BabyRecordDetailPage extends StatelessWidget {
  final BabyRecordEntry entry;

  const BabyRecordDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(entry.createdAt);

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
            BabyRecordDetailHeader(date: formattedDate, isPublic: entry.isPublic),
            const SizedBox(height: 16),
            BabyRecordDetailTitleAndImage(title: entry.title),
            const SizedBox(height: 24),
            BabyRecordDetailContent(
              publicContent: entry.publicContent,
              privateContent: entry.privateContent,
            ),
            const SizedBox(height: 24),
            BabyRecordDetailActions(),
          ],
        ),
      ),
    );
  }
}
