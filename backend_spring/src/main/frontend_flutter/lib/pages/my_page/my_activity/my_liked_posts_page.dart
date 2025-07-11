import 'package:flutter/material.dart';
import '../../../models/post/post_api_services.dart';
import '../../../models/post/post_response.dart';
import '../../community/post_detail_page.dart';

class MyLikedPostsPage extends StatefulWidget {
  const MyLikedPostsPage({super.key});

  @override
  State<MyLikedPostsPage> createState() => _MyLikedPostsPageState();
}

class _MyLikedPostsPageState extends State<MyLikedPostsPage> {
  List<PostListItem> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchLikedPosts();
  }

  Future<void> fetchLikedPosts() async {
    try {
      final result = await PostApiService.fetchLikedPosts(page: 0, size: 20);
      setState(() {
        _posts = result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 누른 글 불러오기 실패')),
      );
    }
  }

  String formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('좋아요 누른 글')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? Center(child: Text('좋아요 누른 게시글이 없습니다.'))
          : ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, idx) {
          final post = _posts[idx];
          return ListTile(
            title: Text(post.title),
            subtitle: Text(
                '${post.createdAt.year}-${post.createdAt.month.toString().padLeft(2, '0')}-${post.createdAt.day.toString().padLeft(2, '0')}'
                    ' ${post.createdAt.hour.toString().padLeft(2, '0')}:${post.createdAt.minute.toString().padLeft(2, '0')} | ${post.nickname}'
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailPage(postId: post.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
