import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';
import '../../models/post/post_request.dart';
import 'package:frontend_flutter/models/post/post_response.dart';

enum PostEditMode { create, edit }

class CreatePostPage extends StatefulWidget {
  final PostEditMode mode;
  final PostResponse? post;

  const CreatePostPage({Key? key, required this.mode, this.post}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _postImgController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = ['자유', '팁', '질문', '모임'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _postImgController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final category = _selectedCategory;
    final postImg = _postImgController.text.trim().isEmpty ? null : _postImgController.text.trim();

    if (title.isEmpty || content.isEmpty || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 내용, 카테고리는 필수 입력 항목입니다.')),
      );
      return;
    }

    final postRequest = PostRequest(
      title: title,
      content: content,
      category: category,
      imgUrl: postImg,
      // 작성자는 서버에서 토큰으로 자동 처리. 필요하면 추가
    );

    try {
      await PostApiService.createPost(postRequest: postRequest);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 작성되었습니다!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('게시글 작성 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 작성에 실패했습니다: ${e.toString()}')),
      );
    }
  }

  Future<void> _updatePost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final category = _selectedCategory;
    final postImg = _postImgController.text.trim().isEmpty ? null : _postImgController.text.trim();

    if (title.isEmpty || content.isEmpty || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 내용, 카테고리는 필수 입력 항목입니다.')),
      );
      return;
    }

    try {
      final result = await PostApiService.updatePost(
        widget.post!.id,
        title: title,
        content: content,
        category: category,
        imgUrl: postImg,
      );
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 수정되었습니다!')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('수정 실패');
      }
    } catch (e) {
      print('게시글 수정 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 수정에 실패했습니다: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        title: const Text(
          '글 쓰기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => (value == null || value.isEmpty) ? '카테고리를 선택하세요.' : null,
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
              TextField(
                controller: _postImgController,
                decoration: const InputDecoration(
                  labelText: '이미지 URL (선택)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.mode == PostEditMode.edit) {
                        _updatePost();       // ← 수정 모드일 때
                      } else {
                        _createPost();       // ← 등록 모드일 때
                      }
                    },
                    child: Text(widget.mode == PostEditMode.edit ? '수정하기' : '등록하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
