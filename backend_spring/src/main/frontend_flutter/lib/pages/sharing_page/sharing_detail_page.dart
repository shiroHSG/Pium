import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/screens/sharing_page/sharing_detail_page_ui.dart';
import '../../models/share/sharing_api_service.dart';

class SharingDetailPage extends StatefulWidget {
  final SharingItem item;

  const SharingDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  State<SharingDetailPage> createState() => _SharingDetailPageState();
}

class _SharingDetailPageState extends State<SharingDetailPage> {
  late SharingItem currentItem;
  int likeCount = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    currentItem = widget.item;
    _loadDetailAndLikes();
  }

  // 게시글 상세 정보 + 좋아요 수 불러오기
  Future<void> _loadDetailAndLikes() async {
    try {
      // 🔼 상세 조회 요청 → 조회수 증가 포함
      final updatedItem = await SharingApiService.fetchShareDetail(widget.item.id);

      final count = await SharingApiService.fetchLikes(widget.item.id);

      setState(() {
        currentItem = updatedItem;
        likeCount = count;
      });
    } catch (e) {
      print('상세 정보 또는 좋아요 수 불러오기 실패: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      final liked = await SharingApiService.toggleLike(widget.item.id);
      setState(() {
        isLiked = liked;
        likeCount += liked ? 1 : -1;
      });
    } catch (e) {
      print('좋아요 토글 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SharingDetailPageUI(
      context,
      currentItem,
      likeCount,
      isLiked,
      _toggleLike,
    );
  }
}
