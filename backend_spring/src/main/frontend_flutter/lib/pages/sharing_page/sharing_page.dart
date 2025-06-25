import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_detail_page.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/pages/sharing_page/write_sharing_page.dart';
import 'package:frontend_flutter/screens/sharing_page/sharing_page_ui.dart';

import '../../models/share/sharing_api_service.dart';

class SharingPage extends StatefulWidget {
  const SharingPage({Key? key}) : super(key: key);

  @override
  State<SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  List<SharingItem> _sharingItems = [];
  String selectedCategory = '전체';
  // 주소 필터 추가 가능
  // String selectedCity = '전체'; // 필요 시 주소별 필터용

  List<SharingItem> get filteredItems {
    // 카테고리로만 필터, 필요 시 주소 필터 추가 가능
    if (selectedCategory == '전체') return _sharingItems;
    return _sharingItems.where((item) => item.category == selectedCategory).toList();
    // 주소 필터 추가시:
    // .where((item) => item.addressCity == selectedCity || selectedCity == '전체')
  }

  @override
  void initState() {
    super.initState();
    _loadSharingItems();
  }

  Future<void> _loadSharingItems() async {
    try {
      final items = await SharingApiService.fetchAllShares();
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
      // TODO: 필요시 API 재요청 추가 가능
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
                // 주소 필터 추가 시 여기에 주소 드롭다운도 배치 가능
              ],
            ),
          ),
          Expanded(
            child: _sharingItems.isEmpty
                ? const Center(child: Text('나눔글이 없습니다.'))
                : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return SharingListItem(
                  item: item,
                  onTap: () => _navigateToDetail(item),
                  onFavoriteTap: () => _handleFavorite(item),
                );
              },
            ),
          ),
          SharingActionButtons(
            onWriteTap: _navigateToWritePost,
          ),
        ],
      ),
    );
  }
}
