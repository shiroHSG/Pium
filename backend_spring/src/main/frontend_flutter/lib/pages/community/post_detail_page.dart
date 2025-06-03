// lib/pages/community/post_detail_page.dart
import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/post_response.dart';
import 'package:frontend_flutter/screens/community/post_detail_page_ui.dart';

class PostDetailPage extends StatelessWidget {
  final PostResponse post;

  const PostDetailPage({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        title: const Text(
          '게시글 페이지',
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
              PostDetailHeader(post: post),
              const SizedBox(height: 16),
              PostDetailCategory(category: post.category),
              const SizedBox(height: 16),
              PostDetailTitle(title: post.title),
              const SizedBox(height: 13),
              PostDetailContent(content: post.content),
              const SizedBox(height: 16),
              PostDetailImage(imageUrl: post.postImg),
              const SizedBox(height: 24),
              const PostDetailCommentsHeader(),
              const SizedBox(height: 12),
              const PostDetailCommentPlaceholder(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PostDetailCommentInput(),
    );
  }
}