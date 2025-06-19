import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:frontend_flutter/models/baby_profile.dart';
import 'package:frontend_flutter/screens/baby_record/add_baby_record_page_ui.dart';

import '../../models/child/child_api.dart';
import 'package:frontend_flutter/models/diary/diary_api.dart';

class AddBabyRecordPage extends StatefulWidget {
  const AddBabyRecordPage({super.key});

  @override
  State<AddBabyRecordPage> createState() => _AddBabyRecordPageState();
}

class _AddBabyRecordPageState extends State<AddBabyRecordPage> {
  bool _isPublic = false; // 기본 비공개
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _publicContentController = TextEditingController();
  final TextEditingController _privateContentController = TextEditingController();

  List<BabyProfile> children = [];
  BabyProfile? selectedChild;
  bool _isLoading = true; // ✅ 로딩 상태
  File? selectedImage; // ✅ 이미지 상태 추가

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveBabyRecord() async {
    if (selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이를 선택해주세요.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? existingRecordsJson = prefs.getString('babyRecords');
    List<BabyRecordEntry> existingRecords = [];
    if (existingRecordsJson != null) {
      final List<dynamic> jsonList = jsonDecode(existingRecordsJson);
      existingRecords = jsonList.map((json) => BabyRecordEntry.fromJson(json)).toList();
    }

    final entry = BabyRecordEntry(
      childId: selectedChild!.childId,
      title: _titleController.text.trim().isEmpty ? '(제목 없음)' : _titleController.text.trim(),
      publicContent: _isPublic ? _publicContentController.text : null,
      privateContent: _privateContentController.text,
      published: _isPublic,
      createdAt: DateTime.now(),
    );

    final success = await DiaryApi.saveDiary(entry, image: selectedImage);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일지가 등록되었습니다.')),
      );
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('등록에 실패했습니다. 다시 시도해주세요.')),
      );
    }
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
            if (_isPublic)
              PublicContentInputField(publicContentController: _publicContentController),
            const SizedBox(height: 20),
            PrivateContentInputField(privateContentController: _privateContentController),
            const SizedBox(height: 20),
            ActionButtons(
              onAttachPhoto: _pickImage,
              onComplete: _saveBabyRecord,
            ),
            if (selectedImage != null) ...[
              const SizedBox(height: 16),
              Text('선택한 사진 미리보기:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Image.file(selectedImage!, height: 200),
              TextButton(
                onPressed: () => setState(() => selectedImage = null),
                child: const Text('사진 제거', style: TextStyle(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
