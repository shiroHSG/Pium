import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/services/post_api_services.dart';
import 'package:frontend_flutter/screens/community/create_post_page_ui.dart';

class CreatePostPage extends StatefulWidget {
  final String loggedInUserId; // 로그인한 사용자 아이디를 받을 파라미터

  const CreatePostPage({Key? key, required this.loggedInUserId}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedCategory;
  late final TextEditingController _writerController;

  final List<String> _categories = ['자유', '팁', '질문', '모임'];

  @override
  void initState() {
    super.initState();
    _writerController = TextEditingController(text: widget.loggedInUserId); // 초기값 설정
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _writerController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    final title = _titleController.text;
    final content = _contentController.text;
    final category = _selectedCategory;
    final writer = _writerController.text;

    if (title.isEmpty || content.isEmpty || category == null || writer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 내용, 카테고리를 모두 입력해주세요.')),
      );
      return;
    }

    try {
      await PostApiService.createPost(
        title: title,
        content: content,
        category: category,
        writer: writer,
        postImg: null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 성공적으로 작성되었습니다!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('게시글 작성 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 작성에 실패했습니다: $e')),
      );
    }
  }

  void _attachPhoto() {
    print('사진 첨부');
    // TODO: 사진 첨부 기능 구현
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
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
            color: Colors.white,
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
              WriterTextField(writerController: _writerController),
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