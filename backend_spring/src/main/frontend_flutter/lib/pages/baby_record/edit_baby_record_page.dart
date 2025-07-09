import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_flutter/models/baby_record_entry.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/diary/diary_api.dart';

class EditBabyRecordPage extends StatefulWidget {
  final BabyRecordEntry entry;

  const EditBabyRecordPage({super.key, required this.entry});

  @override
  State<EditBabyRecordPage> createState() => _EditBabyRecordPageState();
}

class _EditBabyRecordPageState extends State<EditBabyRecordPage> {
  late TextEditingController titleController;
  late TextEditingController privateController;
  TextEditingController? publicController;
  bool isPublic = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.entry.title ?? '');
    privateController = TextEditingController(text: widget.entry.privateContent ?? '');
    isPublic = widget.entry.published;
    publicController = TextEditingController(text: widget.entry.publicContent ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    privateController.dispose();
    publicController?.dispose();
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

  void _removeImage() {
    setState(() {
      selectedImage = null;
      widget.entry.imageUrl = null; // ✅ 기존 이미지 URL도 제거
    });
  }

  Future<void> _submitEdit() async {
    final updated = BabyRecordEntry(
      id: widget.entry.id,
      childId: widget.entry.childId,
      title: titleController.text,
      publicContent: isPublic ? publicController?.text : null,
      privateContent: privateController.text,
      published: isPublic,
      createdAt: widget.entry.createdAt,
      imageUrl: widget.entry.imageUrl,
    );

    final success = await DiaryApi.updateDiary(updated, selectedImage);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? '수정이 완료되었습니다.' : '수정에 실패했습니다.'),
      ));
      if (success) Navigator.pop(context, true);
    }
  }

  Widget _buildImagePreview() {
    if (selectedImage != null) {
      return Image.file(selectedImage!, height: 200, fit: BoxFit.cover);
    } else if (widget.entry.imageUrl != null && widget.entry.imageUrl!.isNotEmpty) {
      return Image.network(widget.entry.imageUrl!, height: 200, fit: BoxFit.cover);
    } else {
      return const Text('이미지가 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('육아일지 수정'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('공개 여부'),
            Switch(
              value: isPublic,
              onChanged: (value) {
                setState(() {
                  isPublic = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('제목'),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '제목을 입력하세요',
              ),
            ),
            const SizedBox(height: 16),
            if (isPublic && publicController != null) ...[
              const Text('자유 게시판 공유 내용'),
              const SizedBox(height: 8),
              TextField(
                controller: publicController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '공개할 내용을 입력하세요',
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text('내 아이 일기'),
            const SizedBox(height: 8),
            TextField(
              controller: privateController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '아이의 하루를 입력하세요',
              ),
            ),
            const SizedBox(height: 24),
            const Text('사진 업로드'),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('사진 선택'),
                ),
                const SizedBox(width: 12),
                if (selectedImage != null || (widget.entry.imageUrl != null && widget.entry.imageUrl!.isNotEmpty))
                  ElevatedButton(
                    onPressed: _removeImage,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('삭제'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildImagePreview(),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _submitEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('수정 완료', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
