import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/baby_record/add_baby_record_page.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:intl/intl.dart';

class BabyRecordPage extends StatefulWidget {
  const BabyRecordPage({super.key});

  @override
  State<BabyRecordPage> createState() => _BabyRecordPageState();
}

class _BabyRecordPageState extends State<BabyRecordPage> {
  List<BabyRecordEntry> babyRecords = [];

  @override
  void initState() {
    super.initState();
    _loadBabyRecords();
  }

  Future<void> _loadBabyRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('babyRecords');
    if (recordsJson != null) {
      final List<dynamic> jsonList = jsonDecode(recordsJson);
      setState(() {
        // 일지를 최신 순으로 정렬 (선택 사항)
        babyRecords = jsonList.map((json) => BabyRecordEntry.fromJson(json)).toList();
        babyRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신 날짜가 위로 오도록 정렬
      });
    } else {
      setState(() {
        babyRecords = [];
      });
    }
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          // 아이 정보
          Container(
            width: screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: AppTheme.lightPink,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 아기 사진
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
                // 이름 및 생년월일
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
          ),

          // 드롭다운 + 플러스 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 드롭다운 버튼
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
                // 플러스 버튼
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddBabyRecordPage()),
                    );
                    _loadBabyRecords(); // AddBabyRecordPage에서 돌아왔을 때 데이터 새로고침
                  },
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
          ),

          // 사진 리스트 or 메시지
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: babyRecords.isEmpty
                  ? const Center(
                child: Text(
                  '불러올 일지가 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : GridView.builder(
                itemCount: babyRecords.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final entry = babyRecords[index];
                  // 날짜 포맷터 생성
                  final DateFormat formatter = DateFormat('yy.MM.dd');
                  final String formattedDate = formatter.format(entry.createdAt);

                  return GestureDetector(
                    onLongPress: () => _deleteBabyRecord(index),
                    child: Container(
                      color: AppTheme.lightPink.withOpacity(0.5),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate, // 날짜 표시
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}