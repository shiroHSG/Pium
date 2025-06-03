import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class CategorySelection extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categories;
  final Function(String?) onCategorySelected;

  const CategorySelection({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
            children: categories.map((category) => _buildCategorySelectionButton(category, selectedCategory, onCategorySelected)).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategorySelectionButton(String category, String? selectedCategory, Function(String?) onCategorySelected) {
    bool isSelected = (selectedCategory == category);
    return ElevatedButton(
      onPressed: () {
        onCategorySelected(category);
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

class TitleTextField extends StatelessWidget {
  final TextEditingController titleController;

  const TitleTextField({Key? key, required this.titleController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: titleController,
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
    );
  }
}

class ContentTextField extends StatelessWidget {
  final TextEditingController contentController;

  const ContentTextField({Key? key, required this.contentController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: TextField(
        controller: contentController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: '글쓰기',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        style: const TextStyle(color: AppTheme.textPurple),
      ),
    );
  }
}

class WriterTextField extends StatelessWidget {
  final TextEditingController writerController;

  const WriterTextField({Key? key, required this.writerController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: writerController,
      decoration: InputDecoration(
        labelText: '작성자',
        hintText: '작성자 이름을 입력해주세요.',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      enabled: false,
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback onAttachPhoto;
  final VoidCallback onCreatePost;

  const ActionButtons({Key? key, required this.onAttachPhoto, required this.onCreatePost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onAttachPhoto,
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
          onPressed: onCreatePost,
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
    );
  }
}