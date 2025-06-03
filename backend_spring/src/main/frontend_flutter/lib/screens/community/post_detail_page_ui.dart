import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/post_response.dart';

class PostDetailHeader extends StatelessWidget {
  final PostResponse post;

  const PostDetailHeader({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, size: 40, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.writer,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '조회수 ${post.viewCount} | 작성일 : ${post.createdAt}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          color: AppTheme.primaryPurple,
          onPressed: () {},
        ),
      ],
    );
  }
}

class PostDetailCategory extends StatelessWidget {
  final String category;

  const PostDetailCategory({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightPink,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PostDetailTitle extends StatelessWidget {
  final String title;

  const PostDetailTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPurple,
      ),
    );
  }
}

class PostDetailContent extends StatelessWidget {
  final String content;

  const PostDetailContent({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class PostDetailImage extends StatelessWidget {
  final String? imageUrl;

  const PostDetailImage({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade200,
        ),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class PostDetailCommentsHeader extends StatelessWidget {
  const PostDetailCommentsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '댓글',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPurple,
      ),
    );
  }
}

class PostDetailCommentPlaceholder extends StatelessWidget {
  const PostDetailCommentPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('댓글 기능은 추후 추가 예정입니다.');
  }
}

class PostDetailCommentInput extends StatelessWidget {
  const PostDetailCommentInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppTheme.lightPink,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                style: const TextStyle(color: AppTheme.textPurple),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('등록'),
            ),
          ],
        ),
      ),
    );
  }
}