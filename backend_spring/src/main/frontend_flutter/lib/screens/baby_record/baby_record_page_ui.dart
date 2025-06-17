import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';

import '../../models/baby_profile.dart';

class BabyRecordHeader extends StatelessWidget {
  final List<BabyProfile> children;
  final BabyProfile? selectedChild;
  final void Function(BabyProfile?) onChildChanged;


  const BabyRecordHeader({
    super.key,
    required this.children,
    required this.selectedChild,
    required this.onChildChanged,
  });

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
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedChild?.name ?? '이름 없음',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.textPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedChild?.birthDate != null
                      ? DateFormat('yyyy.MM.dd').format(selectedChild!.birthDate!)
                      : '생년월일 없음',
                  style: const TextStyle(
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
  final BabyProfile? selectedChild;
  final List<BabyProfile> children;
  final void Function(BabyProfile?) onChildChanged;
  final VoidCallback onAddPressed;

  const BabyRecordFilterAndAdd({
    super.key,
    required this.selectedChild,
    required this.children,
    required this.onChildChanged,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ 드롭다운 실제 구현
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppTheme.primaryPurple,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BabyProfile>(
                value: selectedChild,
                onChanged: onChildChanged,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                dropdownColor: AppTheme.primaryPurple,
                style: const TextStyle(color: Colors.white),
                items: children.map((child) {
                  return DropdownMenuItem<BabyProfile>(
                    value: child,
                    child: Text(child.name ?? '이름 없음'),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ➕ 버튼
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
              entry.published ? '공개' : '비공개',
              style: TextStyle(
                fontSize: 12,
                color: entry.published ? Colors.green : Colors.red,
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