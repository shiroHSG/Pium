import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/models/sharing_page/sharing_api_service.dart';
import '../../sharing_page/sharing_detail_page.dart';

class MyWrittenSharesPage extends StatefulWidget {
  const MyWrittenSharesPage({super.key});

  @override
  State<MyWrittenSharesPage> createState() => _MyWrittenSharesPageState();
}

class _MyWrittenSharesPageState extends State<MyWrittenSharesPage> {
  List<SharingItem> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchMyShares();
  }

  Future<void> fetchMyShares() async {
    setState(() => _loading = true);
    try {
      // 반드시 fetchMyShares API가 구현되어 있어야 함!
      final result = await SharingApiService.fetchMyShares(page: 0, size: 20);
      print('[DEBUG] 내가 쓴 나눔글 결과: $result');
      setState(() {
        _posts = result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print('[ERROR] 내가 쓴 나눔글 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내가 쓴 나눔글 목록 불러오기 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('작성한 글')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? const Center(child: Text('작성한 글이 없습니다.'))
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
