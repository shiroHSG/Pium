import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/models/share/sharing_api_service.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import 'package:frontend_flutter/screens/sharing_page/write_sharing_page_ui.dart';
import 'sharing_page.dart';

class WriteSharingPostPage extends StatefulWidget {
  final bool isEdit;
  final SharingItem? item;

  const WriteSharingPostPage({
    Key? key,
    this.isEdit = false,
    this.item,
  }) : super(key: key);

  @override
  State<WriteSharingPostPage> createState() => _WriteSharingPostPageState();
}

class _WriteSharingPostPageState extends State<WriteSharingPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  File? _selectedImage; // 새로 첨부한 이미지
  bool _imageRemoved = false;    // 기존 이미지 삭제 여부

  int _selectedIndex = 0;
  bool _isLoggedIn = true;
  String _selectedCategory = '나눔';

  @override
  void initState() {
    super.initState();
    // 수정 모드라면 기존 값 세팅
    if (widget.isEdit && widget.item != null) {
      _titleController.text = widget.item!.name;
      _detailsController.text = widget.item!.content;
      _selectedCategory = widget.item!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

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
        _imageRemoved = false; // 새 이미지 선택시 삭제상태 해제
      });
      print('선택된 이미지 경로: ${picked.path}');
    }
  }

  void _handleRemoveImage() {
    setState(() {
      _selectedImage = null;
      _imageRemoved = true;
    });
  }

  Future<void> _handleComplete() async {
    final title = _titleController.text.trim();
    final content = _detailsController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해 주세요.')),
      );
      return;
    }

    try {
      if (widget.isEdit && widget.item != null) {
        await SharingApiService.updateShare(
          id: widget.item!.id,
          title: title,
          content: content,
          category: _selectedCategory,
          imageFile: _imageRemoved ? null : _selectedImage,
        );
      } else {
        await SharingApiService.createShare(
          title: title,
          content: content,
          category: _selectedCategory,
          imageFile: _selectedImage,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? '글이 수정되었습니다.' : '글이 등록되었습니다.')),
        );
      }
    } catch (e) {
      print('글 등록/수정 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('글 등록/수정에 실패했습니다.')),
      );
    }
  }

  Widget _buildImagePreview() {
    // 새로 선택된 이미지가 있으면 FileImage로 보여주기
    if (_selectedImage != null) {
      return Row(
        children: [
          Container(
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
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _handleRemoveImage,
            tooltip: '이미지 삭제',
          ),
        ],
      );
    }
    // 수정모드+기존 이미지 있을 때 (삭제안됨)
    else if (widget.isEdit && widget.item?.imageUrl != null && !_imageRemoved) {
      return Row(
        children: [
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(widget.item!.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _handleRemoveImage,
            tooltip: '이미지 삭제',
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WriteSharingAppBar(),
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
            _buildImagePreview(),
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
