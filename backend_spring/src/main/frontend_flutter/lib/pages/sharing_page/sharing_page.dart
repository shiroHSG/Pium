import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_detail_page.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/pages/sharing_page/write_sharing_page.dart';
import 'package:frontend_flutter/screens/sharing_page/sharing_page_ui.dart';
import 'package:frontend_flutter/models/sharing_page/sharing_api_service.dart';


class SharingPage extends StatefulWidget {
  const SharingPage({Key? key}) : super(key: key);

  @override
  State<SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  List<SharingItem> _sharingItems = []; // 빈 리스트로 초기화
  String selectedCategory = '나눔';

  @override
  void initState() {
    super.initState();
    _loadSharingItems(); // 페이지 시작 시 API 호출
  }

  Future<void> _loadSharingItems() async {
    try {
      final items = await SharingApiService.fetchAllShares(); // API 호출
      setState(() {
        _sharingItems = items;
      });
    } catch (e) {
      print('나눔글 불러오기 실패: $e');
    }
  }

  void _navigateToDetail(SharingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SharingDetailPage(item: item)),
    );
  }

  void _navigateToWritePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WriteSharingPostPage()),
    );
  }

  void _handleRequestShare() {
    // TODO: 나눔 요청하기 기능 구현
    print('나눔 요청하기 버튼 클릭');
  }

  void _handleFavorite(SharingItem item) {
    // TODO: 찜 기능 구현
    print('${item.name} 찜하기');
  }

  void _handleCategoryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedCategory = newValue;
      });
      // TODO: 카테고리별 필터링이 필요하다면 여기에 API 재요청 로직도 추가 가능
      print('선택된 카테고리: $selectedCategory');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharingAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('함께함', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SharingCategoryDropdown(
                  selectedCategory: selectedCategory,
                  onCategoryChanged: _handleCategoryChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sharingItems.length,
              itemBuilder: (context, index) {
                final item = _sharingItems[index];
                return SharingListItem(
                  item: item,
                  onTap: () => _navigateToDetail(item),
                  onFavoriteTap: () => _handleFavorite(item),
                );
              },
            ),
          ),
          SharingActionButtons(
            onRequestTap: _handleRequestShare,
            onWriteTap: _navigateToWritePost,
          ),
        ],
      ),
    );
  }
}