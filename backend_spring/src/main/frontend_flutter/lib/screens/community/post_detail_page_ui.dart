import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/post/post_response.dart';
import 'package:frontend_flutter/models/post/post_comment.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';

import '../../widgets/fullscreen_image.dart';
import '../../widgets/protected_image.dart';

// 1. 프로필/헤더
class PostDetailHeader extends StatefulWidget {
  final PostResponse post;
  const PostDetailHeader({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailHeader> createState() => _PostDetailHeaderState();
}

class _PostDetailHeaderState extends State<PostDetailHeader> {
  late bool isLiked;
  late int likeCount;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isLiked;
    likeCount = widget.post.likeCount;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleLike() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      // 1. UI 먼저 반영
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    final success = await PostApiService.toggleLike(widget.post.id);

    if (!success) {
      // 2. 실패 시 롤백
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 처리 실패')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 프로필 이미지
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.person, size: 32, color: Colors.grey[400]),
        ),
        const SizedBox(width: 12),
        // 닉네임, 조회수, 날짜
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.author,
                style: const TextStyle(
                  fontFamily: 'Jua',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPurple,
                ),
              ),
              const SizedBox(height: 2),
              // ★ 조회수 및 작성일 표시 (아래처럼 추가!)
              Row(
                children: [
                  Text(
                    '조회수 ${widget.post.viewCount} | 작성일 : ${_formatDate(widget.post.createdAt)}',
                    style: TextStyle(
                      fontFamily: 'Jua',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),


        // 하트 & 좋아요 수
        IconButton(
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.pink),
          onPressed: isLoading ? null : _toggleLike,
        ),
        Text(
          '$likeCount',
          style: const TextStyle(
            fontFamily: 'Jua',
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// 2. 카테고리 태그
class PostDetailCategory extends StatelessWidget {
  final String category;
  const PostDetailCategory({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightPink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 14,
          color: AppTheme.textPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// 3. 제목
class PostDetailTitle extends StatelessWidget {
  final String title;
  const PostDetailTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Jua',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPurple,
      ),
    );
  }
}

// 4. 본문
class PostDetailContent extends StatelessWidget {
  final String content;
  const PostDetailContent({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// 5. 이미지
class PostDetailImage extends StatelessWidget {
  final String? imageUrl;
  const PostDetailImage({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullscreenImagePage(imageUrl: imageUrl!),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade200,
        ),
        clipBehavior: Clip.antiAlias,
        child: ProtectedImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
// 전체 이미지 보이기
class FullscreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullscreenImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FullscreenImage(
            imageUrl: imageUrl,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// 6. 댓글 섹션 (입력 포함)
class CommentSection extends StatefulWidget {
  final int postId;
  const CommentSection({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  List<Comment> comments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshComments();
  }

  Future<void> _refreshComments() async {
    setState(() => isLoading = true);
    final list = await PostApiService.fetchComments(widget.postId);
    setState(() {
      comments = list;
      isLoading = false;
    });
  }

  Future<void> _addComment(String content) async {
    if (content.trim().isEmpty) return;
    await PostApiService.addComment(widget.postId, content);
    await _refreshComments();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '댓글',
          style: TextStyle(
            fontFamily: 'Jua',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPurple,
          ),
        ),
        const SizedBox(height: 10),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : CommentList(comments: comments),
        const SizedBox(height: 14),
        CommentInput(onSubmit: _addComment),
      ],
    );
  }
}

// 7. 댓글 리스트
class CommentList extends StatelessWidget {
  final List<Comment> comments;
  const CommentList({Key? key, required this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Text('아직 댓글이 없습니다.', style: TextStyle(color: Colors.grey, fontFamily: 'Jua')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, idx) {
        final comment = comments[idx];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: AppTheme.textPurple),
                  const SizedBox(width: 7),
                  Text(comment.writer, style: const TextStyle(fontFamily: 'Jua', fontWeight: FontWeight.bold, color: AppTheme.textPurple)),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.content, style: const TextStyle(fontFamily: 'Jua', fontSize: 15)),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  comment.createdAt.split('T').first, // 날짜만
                  style: const TextStyle(fontFamily: 'Jua', fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 8. 댓글 입력창
class CommentInput extends StatefulWidget {
  final Function(String) onSubmit;
  const CommentInput({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isLoading) return;
    setState(() => isLoading = true);
    await widget.onSubmit(text);
    _controller.clear();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(fontFamily: 'Jua', fontSize: 15),
            decoration: InputDecoration(
              hintText: '댓글을 입력하세요.',
              hintStyle: const TextStyle(fontFamily: 'Jua', color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.lightPink,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            textStyle: const TextStyle(fontFamily: 'Jua', fontWeight: FontWeight.bold, fontSize: 15),
          ),
          child: isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('등록'),
        ),
      ],
    );
  }
}
