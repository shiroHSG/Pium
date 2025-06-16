import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:frontend_flutter/screens/baby_record/baby_record_page_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:frontend_flutter/pages/baby_record/baby_record_detail_page.dart';

import '../../models/baby_profile.dart';
import '../../models/child/child_api.dart';
import 'add_baby_record_page.dart';

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
      _loadBabyRecords(result.first.childId!); // 초기 선택된 아이 기준 일지 로드
    }
  }

  Future<void> _loadBabyRecords(int childId) async {
    // TODO: childId 기준으로 육아일지 조회 API 호출
    // 임시: 빈 리스트로 설정
    setState(() {
      babyRecords = []; // 여기에 fetch 로직 넣기
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
    final prefs = await SharedPreferences.getInstance();
    final String updatedRecordsJson = jsonEncode(babyRecords.map((e) => e.toJson()).toList());
    await prefs.setString('babyRecords', updatedRecordsJson);
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BabyRecordDetailPage(
                            entry: entry,
                          ),
                        ),
                      );
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