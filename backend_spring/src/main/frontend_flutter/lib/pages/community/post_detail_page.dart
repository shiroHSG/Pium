import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/post/post_response.dart';
import 'package:frontend_flutter/screens/community/post_detail_page_ui.dart';

import 'package:frontend_flutter/models/auth/auth_services.dart';
import 'package:frontend_flutter/pages/community/create_post_page.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  const PostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  PostResponse? post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    try {
      final fetchedPost = await PostApiService.fetchPostDetail(widget.postId);
      setState(() {
        post = fetchedPost;
        isLoading = false;
      });
    } catch (e) {
      print('게시글 불러오기 실패: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || post == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
              PostDetailHeader(post: post!), // 좋아요 상태 반영됨
              const SizedBox(height: 16),
              PostDetailCategory(category: post!.category),
              const SizedBox(height: 16),
              PostDetailTitle(title: post!.title),
              const SizedBox(height: 13),
              PostDetailContent(content: post!.content),
              const SizedBox(height: 16),
              PostDetailImage(imageUrl: post!.imageUrl),
              const SizedBox(height: 24),

              FutureBuilder<Map<String, dynamic>?>( // 수정/삭제 버튼
                future: AuthService().fetchMemberInfo(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final nickname = snapshot.data!['nickname'];
                  final isOwner = nickname == post!.author;
                  if (!isOwner) return const SizedBox.shrink();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreatePostPage(
                                isEdit: true,
                                post: post!,
                              ),
                            ),
                          );
                        },
                        child: const Text('수정'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('게시글 삭제'),
                              content: const Text('정말 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('삭제'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            final result = await PostApiService.deletePost(post!.id);
                            if (result) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('삭제 완료!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('삭제 실패!')),
                              );
                            }
                          }
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              CommentSection(postId: post!.id),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
