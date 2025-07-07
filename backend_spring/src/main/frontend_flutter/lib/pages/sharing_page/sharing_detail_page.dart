import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/screens/sharing_page/sharing_detail_page_ui.dart';
import 'package:frontend_flutter/pages/sharing_page/write_sharing_page.dart';
import 'package:frontend_flutter/models/sharing_page/sharing_api_service.dart';

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
  int? myMemberId;

  @override
  void initState() {
    super.initState();
    currentItem = widget.item;
    _loadMyMemberId();
    _loadDetailAndLikes();
  }

  // 1️⃣ 로그인된 내 memberId 불러오기 (권한 체크 용도)
  Future<void> _loadMyMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myMemberId = prefs.getInt('memberId');
    });
  }

  // 2️⃣ 상세 정보, 좋아요 수 불러오기
  Future<void> _loadDetailAndLikes() async {
    try {
      final updatedItem = await SharingApiService.fetchShareDetail(widget.item.id);
      final count = await SharingApiService.fetchLikes(widget.item.id);
      setState(() {
        currentItem = updatedItem;
        likeCount = count;
        isLiked = updatedItem.isLiked;
      });
    } catch (e) {
      print('상세 정보 또는 좋아요 수 불러오기 실패: $e');
    }
  }

  // 3️⃣ 좋아요 토글 함수
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

  // 4️⃣ 삭제 버튼 함수
  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정말 삭제하시겠습니까?'),
        content: const Text('삭제된 글은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SharingApiService.deleteShare(widget.item.id);
        if (mounted) {
          Navigator.of(context).pop(); // 목록(이전페이지)으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('글이 삭제되었습니다.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  // 5️⃣ 수정 버튼 함수 (글 수정 페이지로 이동)
  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WriteSharingPostPage(
          isEdit: true,
          item: currentItem,
        ),
      ),
    );
    if (result == true) {
      // 수정 성공시 상세 내용 새로고침
      _loadDetailAndLikes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('글이 수정되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = myMemberId != null && myMemberId == currentItem.authorMemberId;

    return SharingDetailPageUI(
      context,
      currentItem,
      likeCount,
      isLiked,
      _toggleLike,
      canEdit: canEdit,
      onEdit: canEdit ? _navigateToEdit : null,
      onDelete: canEdit ? _handleDelete : null,
    );
  }
}
