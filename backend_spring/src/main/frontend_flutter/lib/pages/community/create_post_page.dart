import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';
import '../../models/post/post_request.dart';
import 'package:frontend_flutter/models/post/post_response.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


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
      // 기존 이미지는 필요시 표시: widget.post!.imageUrl
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
        // 수정
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
        // 등록
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? '글 수정' : '글 쓰기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              minLines: 6,
              maxLines: 15,
            ),
            const SizedBox(height: 16),
            // 이미지 미리보기 및 선택/삭제 UI
            if (_selectedImage != null)
              Stack(
                children: [
                  Image.file(_selectedImage!, height: 150),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: _removeImage,
                    ),
                  ),
                ],
              ),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('이미지 선택'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: _createOrUpdatePost,
                  child: Text(widget.isEdit ? '수정하기' : '등록하기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
