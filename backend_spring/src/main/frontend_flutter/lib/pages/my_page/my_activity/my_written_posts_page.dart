import 'package:flutter/material.dart';
import '../../../models/post/post_api_services.dart';
import '../../community/post_detail_page.dart'; // 상세페이지 위치 맞게 수정

// PostListItem DTO는 post_api_services.dart에 포함되어 있다고 가정
// (만약 별도 파일이면 import만 추가)

class MyWrittenPostsPage extends StatefulWidget {
  const MyWrittenPostsPage({super.key});

  @override
  State<MyWrittenPostsPage> createState() => _MyWrittenPostsPageState();
}

class _MyWrittenPostsPageState extends State<MyWrittenPostsPage> {
  List<PostListItem> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchMyPosts();
  }

  Future<void> fetchMyPosts() async {
    try {
      final result = await PostApiService.fetchMyPosts(page: 0, size: 20);

      print('[DEBUG] 화면에 뿌릴 post 리스트: $result');

      setState(() {
        _posts = result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내가 쓴 글 불러오기 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('내가 쓴 글')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? Center(child: Text('작성한 게시글이 없습니다.'))
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
