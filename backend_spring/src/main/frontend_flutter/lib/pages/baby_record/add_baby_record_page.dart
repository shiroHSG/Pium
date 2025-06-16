import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/screens/baby_record/add_baby_record_page_ui.dart';

import '../../models/child/child_api.dart';

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

  List<BabyProfile> children = [];
  BabyProfile? selectedChild;
  bool _isLoading = true; // ✅ 로딩 상태

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final result = await ChildApi.fetchMyChildren();
    if (result.isNotEmpty) {
      result.sort((a, b) => a.birthDate!.compareTo(b.birthDate!));
      setState(() {
        children = result;
        selectedChild = result.first;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      childId: selectedChild?.childId,
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AddBabyRecordAppBar(
        onCancel: () {
          Navigator.pop(context);
        },
        onNotification: () {},
        onMenu: () {},
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
                BabyNameDropdown(
                  selectedChild: selectedChild,
                  children: children,
                  onChanged: (child) {
                    setState(() {
                      selectedChild = child;
                    });
                  },
                ),
                PublicPrivateSwitch(
                  isPublic: _isPublic,
                  onSwitchChanged: (newValue) {
                    setState(() {
                      _isPublic = newValue;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 25),
            TitleInputField(titleController: _titleController),
            const SizedBox(height: 20),
            PublicContentInputField(publicContentController: _publicContentController),
            const SizedBox(height: 20),
            PrivateContentInputField(privateContentController: _privateContentController),
            const SizedBox(height: 20),
            ActionButtons(
              onAttachPhoto: () {
                // TODO: 사진 첨부 로직 구현
              },
              onComplete: () async {
                await _saveBabyRecord();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
