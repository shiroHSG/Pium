import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';

import '../../models/post/post_request.dart';
import '../../screens/community/create_post_page_ui.dart';
import '../../widgets/notification_page.dart';

// CreatePostPage 위젯 정의
class CreatePostPage extends StatefulWidget {
  final String loggedInUserId;  // 로그인한 사용자 아이디를 받을 파라미터

  const CreatePostPage({Key? key, required this.loggedInUserId}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _postImgController = TextEditingController();
  String? _selectedCategory;
  late final TextEditingController _writerController;

  final List<String> _categories = ['자유', '팁', '질문', '모임'];

  @override
  void initState() {
    super.initState();
    _writerController = TextEditingController(text: widget.loggedInUserId);  // 초기값 설정
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _postImgController.dispose();
    // _writerController.dispose();
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
      postImg: postImg,
    );

    try {
      await PostApiService.createPost(postRequest: postRequest); // PostApiService 사용
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 작성되었습니다!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('createPost 게시글 작성 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('createPost 게시글 작성에 실패했습니다: ${e.toString()}')),
      );
    }
  }

  void _attachPhoto() {
    print('사진 첨부 기능 구현 필요');
  }

  void _handleCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySelection(
                selectedCategory: _selectedCategory,
                categories: _categories,
                onCategorySelected: _handleCategorySelected,
              ),
              TitleTextField(titleController: _titleController),
              const SizedBox(height: 16),
              ContentTextField(contentController: _contentController),
              const SizedBox(height: 16),
              // WriterTextField(writerController: _writerController),
              const SizedBox(height: 24),
              ActionButtons(
                onAttachPhoto: _attachPhoto,
                onCreatePost: _createPost,
              ),
            ],
          ),
        ),
      ),
    );
  }
}