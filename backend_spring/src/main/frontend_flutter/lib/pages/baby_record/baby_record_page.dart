import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:frontend_flutter/pages/baby_record/add_baby_record_page.dart';
import 'package:frontend_flutter/pages/baby_record/baby_record_detail_page.dart';

import '../../models/child/child_api.dart';
import '../../models/diary/diary_api.dart'; // 📌 API 불러오기

import '../../screens/baby_record/baby_record_page_ui.dart';

class BabyRecordPage extends StatefulWidget {
  const BabyRecordPage({super.key});

  @override
  State<BabyRecordPage> createState() => _BabyRecordPageState();
}

class _BabyRecordPageState extends State<BabyRecordPage> {
  List<BabyProfile> children = [];
  BabyProfile? selectedChild;
  List<BabyRecordEntry> babyRecords = [];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final result = await ChildApi.fetchMyChildren();
    if (result.isNotEmpty) {
      result.sort((a, b) => a.birthDate!.compareTo(b.birthDate!)); // 나이순
      setState(() {
        children = result;
        selectedChild = result.first;
      });
      _loadBabyRecords(result.first.childId!);
    }
  }

  Future<void> _loadBabyRecords(int childId) async {
    final diaries = await DiaryApi.fetchDiariesByChildId(childId); // ✅ 새 API 호출
    setState(() {
      babyRecords = diaries;
    });
  }

  void _onChildChanged(BabyProfile? newChild) {
    if (newChild == null) return;
    setState(() {
      selectedChild = newChild;
    });
    _loadBabyRecords(newChild.childId!);
  }

  Future<void> _deleteBabyRecord(int index) async {
    setState(() {
      babyRecords.removeAt(index);
    });
    // 실제 서버에서 삭제 API 호출하려면 여기에 추가 가능
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일지가 삭제되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BabyRecordHeader(
            children: children,
            selectedChild: selectedChild,
            onChildChanged: _onChildChanged,
          ),
          BabyRecordFilterAndAdd(
            selectedChild: selectedChild,
            children: children,
            onChildChanged: _onChildChanged,
            onAddPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBabyRecordPage()),
              );
              if (selectedChild != null) {
                _loadBabyRecords(selectedChild!.childId!);
              }
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: babyRecords.isEmpty
                  ? const EmptyBabyRecordList()
                  : GridView.builder(
                itemCount: babyRecords.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final entry = babyRecords[index];
                  return BabyRecordGridItem(
                    entry: entry,
                    onDelete: _deleteBabyRecord,
                    index: index,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BabyRecordDetailPage(entry: entry),
                        ),
                      );
                      if (result == true && selectedChild != null) {
                        _loadBabyRecords(selectedChild!.childId!); // 변경된 일지 다시 로드
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
