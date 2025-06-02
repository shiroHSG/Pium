import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';

class BabyRecordHeader extends StatelessWidget {
  const BabyRecordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: const BoxDecoration(
        color: AppTheme.lightPink,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const Center(
              child: Text(
                '아이\n사진',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이름',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textPurple,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '생년월일',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BabyRecordFilterAndAdd extends StatelessWidget {
  final VoidCallback onAddPressed;

  const BabyRecordFilterAndAdd({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppTheme.primaryPurple,
            ),
            child: Row(
              children: const [
                Text(
                  '이름',
                  style: TextStyle(color: Colors.white),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAddPressed,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryPurple,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class BabyRecordGridItem extends StatelessWidget {
  final BabyRecordEntry entry;
  final Function(int) onDelete;
  final int index;
  final VoidCallback onTap;

  const BabyRecordGridItem({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yy.MM.dd');
    final String formattedDate = formatter.format(entry.createdAt);

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => onDelete(index),
      child: Container(
        color: AppTheme.lightPink.withOpacity(0.5),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  entry.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPurple),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Text(
              entry.isPublic ? '공개' : '비공개',
              style: TextStyle(
                fontSize: 12,
                color: entry.isPublic ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyBabyRecordList extends StatelessWidget {
  const EmptyBabyRecordList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '불러올 일지가 없습니다',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}