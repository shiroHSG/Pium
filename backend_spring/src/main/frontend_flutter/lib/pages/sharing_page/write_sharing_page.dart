// lib/pages/sharing_page/write_sharing_page.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
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

  bool _isLoggedIn = true;
  int _selectedIndex = 0;

  String _selectedCategory = '나눔';

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;  // 아이템 선택
    });
  }

  void _onLoginStatusChanged(bool status) {
    setState(() {
      _isLoggedIn = status;  // 로그인 상태 변경
    });
  }

  void _handleCategoryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCategory = newValue;  // 카테고리 변경
      });
    }
  }

  void _handleAttachPhoto() {
    // TODO: 사진 첨부 기능 구현
    print('사진 첨부');
  }

  void _handleComplete() {
    // TODO: 작성 완료 및 저장 로직 구현
    print('제목: ${_titleController.text}, 상세 내용: ${_detailsController.text}, 카테고리: $_selectedCategory');
    Navigator.pop(context);
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
        isLoggedIn: _isLoggedIn,
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