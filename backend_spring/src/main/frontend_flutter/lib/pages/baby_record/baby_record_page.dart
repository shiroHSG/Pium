import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:frontend_flutter/screens/baby_record/baby_record_page_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:frontend_flutter/pages/baby_record/baby_record_detail_page.dart';

import 'add_baby_record_page.dart';

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
    return Scaffold(
      body: Column(
        children: [
          const BabyRecordHeader(),
          BabyRecordFilterAndAdd(
            onAddPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBabyRecordPage()),
              );
              _loadBabyRecords();
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