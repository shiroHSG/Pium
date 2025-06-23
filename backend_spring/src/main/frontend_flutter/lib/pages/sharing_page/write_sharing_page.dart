import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_flutter/models/sharing_page/sharing_api_service.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import 'package:frontend_flutter/screens/sharing_page/write_sharing_page_ui.dart';

class WriteSharingPostPage extends StatefulWidget {
  const WriteSharingPostPage({Key? key}) : super(key: key);

  @override
  State<WriteSharingPostPage> createState() => _WriteSharingPostPageState();
}

class _WriteSharingPostPageState extends State<WriteSharingPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  File? _selectedImage;

  bool _isLoggedIn = true;
  int _selectedIndex = 0;
  String _selectedCategory = '나눔';

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onLoginStatusChanged(bool status) {
    setState(() {
      _isLoggedIn = status;
    });
  }

  void _handleCategoryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCategory = newValue;
      });
    }
  }

  Future<void> _handleAttachPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
      print('선택된 이미지 경로: ${picked.path}');
    }
  }

  void _handleComplete() async {
    final title = _titleController.text.trim();
    final content = _detailsController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해 주세요.')),
      );
      return;
    }

    try {
      await SharingApiService.createShare(
        title: title,
        content: content,
        imageFile: _selectedImage,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SharingPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('나눔 글이 등록되었습니다.')),
        );
      }
    } catch (e) {
      print('글 등록 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('글 등록에 실패했습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WriteSharingAppBar(),
      endDrawer: CustomDrawer(
        onItemSelected: _onItemSelected,
        onLoginStatusChanged: _onLoginStatusChanged,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                WriteSharingTitleInput(titleController: _titleController),
                const SizedBox(width: 10),
                WriteSharingCategoryDropdown(
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: _handleCategoryChanged,
                ),
              ],
            ),
            const SizedBox(height: 14),
            WriteSharingDetailsInput(detailsController: _detailsController),
            const SizedBox(height: 20),

            // 이미지 미리보기: 왼쪽 정렬 + 크기 줄임
            if (_selectedImage != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            WriteSharingActionButtons(
              onAttachPhotoPressed: _handleAttachPhoto,
              onCompletePressed: _handleComplete,
            ),
          ],
        ),
      ),
    );
  }
}