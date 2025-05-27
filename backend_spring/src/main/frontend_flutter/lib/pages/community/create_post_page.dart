import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        title: const Text(
          '커뮤니티 글 쓰기',
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
              const Text(
                '카테고리',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPurple,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildCategorySelectionButton('자유'),
                    _buildCategorySelectionButton('팁'),
                    _buildCategorySelectionButton('질문'),
                    _buildCategorySelectionButton('모임'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: '제목',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                style: const TextStyle(color: AppTheme.textPurple),
              ),
              const SizedBox(height: 16),
              Container(
                height: 250, // 글쓰기 영역 높이 조정
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: const TextField(
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: '글쓰기',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: TextStyle(color: AppTheme.textPurple),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // 사진 첨부 기능 구현
                      print('사진 첨부');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.photo),
                    label: const Text('사진 첨부'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 완료 버튼 기능 구현 (글 작성 완료 후 페이지 닫기 등)
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('완료'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelectionButton(String category) {
    bool isSelected = (_selectedCategory == category);
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primaryPurple : AppTheme.lightPink,
        foregroundColor: isSelected ? Colors.white : AppTheme.textPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.primaryPurple.withOpacity(isSelected ? 1.0 : 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
      ),
      child: Text(category, style: const TextStyle(fontSize: 14)),
    );
  }
}