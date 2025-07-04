import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';
import 'package:frontend_flutter/models/post/post_response.dart';

import '../../screens/community/create_post_page_ui.dart';

class CreatePostPage extends StatefulWidget {
  final bool isEdit;
  final PostResponse? post;

  const CreatePostPage({Key? key, this.isEdit = false, this.post}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedCategory;
  File? _selectedImage;

  final List<String> _categories = ['자유', '팁', '질문', '모임'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _selectedCategory = widget.post!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _createOrUpdatePost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final category = _selectedCategory;

    if (title.isEmpty || content.isEmpty || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 내용, 카테고리는 필수 입력 항목입니다.')),
      );
      return;
    }

    try {
      if (widget.isEdit && widget.post != null) {
        await PostApiService.updatePostMultipart(
          postId: widget.post!.id,
          title: title,
          content: content,
          category: category,
          imageFile: _selectedImage,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 수정되었습니다!')),
        );
      } else {
        await PostApiService.createPostMultipart(
          title: title,
          content: content,
          category: category,
          imageFile: _selectedImage,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 작성되었습니다!')),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      print('게시글 등록/수정 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 등록/수정 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildCreatePostScaffold(
      context: context,
      isEdit: widget.isEdit,
      selectedCategory: _selectedCategory,
      categories: _categories,
      onCategorySelected: (value) => setState(() => _selectedCategory = value),
      titleController: _titleController,
      contentController: _contentController,
      selectedImage: _selectedImage,
      onRemoveImage: _removeImage,
      onPickImage: _pickImage,
      onCreateOrUpdatePost: _createOrUpdatePost,
    );
  }
}
