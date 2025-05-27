import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:frontend_flutter/models/baby_record_entry.dart';

class AddBabyRecordPage extends StatefulWidget {
  const AddBabyRecordPage({super.key});

  @override
  State<AddBabyRecordPage> createState() => _AddBabyRecordPageState();
}

class _AddBabyRecordPageState extends State<AddBabyRecordPage> {
  bool _isPublic = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _publicContentController = TextEditingController();
  final TextEditingController _privateContentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _publicContentController.dispose();
    _privateContentController.dispose();
    super.dispose();
  }

  Future<void> _saveBabyRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingRecordsJson = prefs.getString('babyRecords');
    List<BabyRecordEntry> existingRecords = [];
    if (existingRecordsJson != null) {
      final List<dynamic> jsonList = jsonDecode(existingRecordsJson);
      existingRecords = jsonList.map((json) => BabyRecordEntry.fromJson(json)).toList();
    }

    final newEntry = BabyRecordEntry(
      title: _titleController.text.trim().isEmpty ? '(제목 없음)' : _titleController.text.trim(),
      publicContent: _publicContentController.text,
      privateContent: _privateContentController.text,
      isPublic: _isPublic,
      createdAt: DateTime.now(),
    );

    existingRecords.add(newEntry);

    final String updatedRecordsJson = jsonEncode(existingRecords.map((e) => e.toJson()).toList());
    await prefs.setString('babyRecords', updatedRecordsJson);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일지가 임시 저장되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightPink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPurple),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '피움',
          style: TextStyle(
            color: AppTheme.textPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.textPurple),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.textPurple),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppTheme.primaryPurple,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '이름',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isPublic ? '공개' : '비공개',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isPublic,
                      onChanged: (newValue) {
                        setState(() {
                          _isPublic = newValue;
                        });
                      },
                      activeColor: AppTheme.primaryPurple,
                      inactiveTrackColor: Colors.grey[300],
                      inactiveThumbColor: Colors.grey[500],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              height: 150,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: _publicContentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '내용을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              height: 200,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: _privateContentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '내 아이 일기 내용을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 사진 첨부 로직 (현재는 단순히 placeholder)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  child: const Text(
                    '사진 첨부',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _saveBabyRecord();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  child: const Text(
                    '완료',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}