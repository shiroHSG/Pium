import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

// UI 전체 Scaffold
Widget buildCreatePostScaffold({
  required BuildContext context,
  required bool isEdit,
  required String? selectedCategory,
  required List<String> categories,
  required Function(String?) onCategorySelected,
  required TextEditingController titleController,
  required TextEditingController contentController,
  required File? selectedImage,
  required VoidCallback onRemoveImage,
  required VoidCallback onPickImage,
  required VoidCallback onCreateOrUpdatePost,
}) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: Text(isEdit ? '글 수정' : '글 쓰기'),
      backgroundColor: AppTheme.primaryPurple,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategorySelection(
            selectedCategory: selectedCategory,
            categories: categories,
            onCategorySelected: onCategorySelected,
          ),
          TitleTextField(titleController: titleController),
          const SizedBox(height: 16),
          ContentTextField(contentController: contentController),
          const SizedBox(height: 16),
          if (selectedImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(selectedImage, height: 150),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onRemoveImage,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          ActionButtons(
            onAttachPhoto: onPickImage,
            onCreatePost: onCreateOrUpdatePost,
          ),
        ],
      ),
    ),
  );
}

// ✅ 카테고리 선택 위젯
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
            children: categories
                .map((category) => _buildCategorySelectionButton(category))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategorySelectionButton(String category) {
    final bool isSelected = selectedCategory == category;
    return ElevatedButton(
      onPressed: () => onCategorySelected(category),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primaryPurple : AppTheme.lightPink,
        foregroundColor: isSelected ? Colors.white : AppTheme.textPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(isSelected ? 1.0 : 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
      ),
      child: Text(category, style: const TextStyle(fontSize: 14)),
    );
  }
}

// ✅ 제목 입력 위젯
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

// ✅ 내용 입력 위젯
class ContentTextField extends StatelessWidget {
  final TextEditingController contentController;

  const ContentTextField({Key? key, required this.contentController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
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

// ✅ 사진 첨부 & 작성 완료 버튼
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
