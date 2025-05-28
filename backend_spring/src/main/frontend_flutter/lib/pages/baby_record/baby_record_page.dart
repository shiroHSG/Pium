import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/baby_record/add_baby_record_page.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:intl/intl.dart';

class BabyRecordDetailPage extends StatelessWidget {
  final String title;
  final DateTime createdAt;
  final bool isPublic;

  const BabyRecordDetailPage({
    super.key,
    required this.title,
    required this.createdAt,
    required this.isPublic,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy년 MM월 dd일 HH시 mm분');
    final String formattedDate = formatter.format(createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('육아일지 상세'),
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
                  isPublic ? '공개' : '비공개',
                  style: TextStyle(
                    fontSize: 16,
                    color: isPublic ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                  '여기에 이미지가 표시될 예정입니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '아직 내용이 없습니다.',
              style: TextStyle(fontSize: 16),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('삭제는 목록 화면에서 가능합니다.')),
                    );
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
        babyRecords = jsonList.map((json) => BabyRecordEntry.fromJson(json)).toList();
        babyRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
          Container(
            width: screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
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
          Padding(
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddBabyRecordPage()),
                    );
                    _loadBabyRecords();
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
                  final DateFormat formatter = DateFormat('yy.MM.dd');
                  final String formattedDate = formatter.format(entry.createdAt);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BabyRecordDetailPage(
                            title: entry.title,
                            createdAt: entry.createdAt,
                            isPublic: entry.isPublic,
                          ),
                        ),
                      );
                    },
                    onLongPress: () => _deleteBabyRecord(index),
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}