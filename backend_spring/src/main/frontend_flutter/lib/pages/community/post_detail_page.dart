import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/post/post_response.dart';
import 'package:frontend_flutter/screens/community/post_detail_page_ui.dart';

import 'package:frontend_flutter/models/auth/auth_services.dart';
import 'package:frontend_flutter/pages/community/create_post_page.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';


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
              // ... (프로필, 제목, 내용 등)
              PostDetailHeader(post: post),
              SizedBox(height: 16),
              PostDetailCategory(category: post.category),
              SizedBox(height: 16),
              PostDetailTitle(title: post.title),
              SizedBox(height: 13),
              PostDetailContent(content: post.content),
              SizedBox(height: 16),
              PostDetailImage(imageUrl: post.imgUrl),
              SizedBox(height: 24),

              // ✨ 수정/삭제 버튼만 있는 줄 (FutureBuilder)
              FutureBuilder<Map<String, dynamic>?>(
                future: AuthService().fetchMemberInfo(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final nickname = snapshot.data!['nickname'];
                  final isOwner = nickname == post.author;
                  if (!isOwner) return SizedBox.shrink();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬(원하면 변경)
                    children: [
                      TextButton(
                        onPressed: () async {
                          // 수정 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreatePostPage(
                                mode: PostEditMode.edit,
                                post: post,
                              ),
                            ),
                          );
                        },
                        child: const Text('수정'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // 삭제 다이얼로그
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
                            final result = await PostApiService.deletePost(post.id);
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
              SizedBox(height: 16),

              // 👇 댓글 타이틀/댓글 목록/입력창 한 번만!
              // Text('댓글', style: TextStyle(/* ... */)),
              CommentSection(postId: post.id),
              SizedBox(height: 12),
              // 댓글 입력 창이 CommentSection에 포함되어 있지 않으면 추가
              // PostDetailCommentInput(postId: post.id, onCommentPosted: ...),
            ],
          ),
        ),
      ),
    );
  }
}