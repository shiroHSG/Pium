import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/models/sharing_page/sharing_api_service.dart';
import '../../sharing_page/sharing_detail_page.dart';

class MyLikedSharesPage extends StatefulWidget {
  const MyLikedSharesPage({super.key});

  @override
  State<MyLikedSharesPage> createState() => _MyLikedSharesPageState();
}

class _MyLikedSharesPageState extends State<MyLikedSharesPage> {
  List<SharingItem> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchLikedShares();
  }

  Future<void> fetchLikedShares() async {
    setState(() => _loading = true);
    try {
      final result = await SharingApiService.fetchLikedShares(page: 0, size: 20);
      print('[DEBUG] 내가 좋아요 한 글 결과: $result');
      setState(() {
        _posts = result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print('[ERROR] 내가 좋아요 한 글 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 누른 나눔글 목록 불러오기 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('좋아요 누른 글')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? const Center(child: Text('좋아요 누른 글이 없습니다.'))
          : ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, idx) {
          final post = _posts[idx];
          return ListTile(
            title: Text(post.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${post.postDate} | ${post.nickname}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SharingDetailPage(item: post)),
              );
            },
          );
        },
      ),
    );
  }
}
