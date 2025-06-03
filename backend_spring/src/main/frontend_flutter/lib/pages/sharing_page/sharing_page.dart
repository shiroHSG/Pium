import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_detail_page.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/pages/sharing_page/write_sharing_page.dart';
import 'package:frontend_flutter/screens/sharing_page/sharing_page_ui.dart';

class SharingPage extends StatefulWidget {
  const SharingPage({Key? key}) : super(key: key);

  @override
  State<SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  final List<SharingItem> _sharingItems = [
    SharingItem(
      name: '[나눔] 아기 바운서 (뉴나 Leaf Curv)',
      details: '직거래, 서울 성북구',
      imageUrl: 'https://via.placeholder.com/150/f0f0f0/000000?Text=Baouncer',
      authorId: '행복육아맘',
      content: '아기가 커서 더 이상 사용하지 않게 된 바운서입니다. 사용 기간은 6개월 정도이며, 깨끗하게 사용했습니다. 직접 오셔서 가져가셔야 합니다.',
      likes: 25,
      views: 300,
      postDate: '2025년 05월 18일',
    ),
    SharingItem(
      name: '[나눔] 기저귀 (하기스 네이처메이드 3단계, 40개 남음)',
      details: '착불 택배',
      imageUrl: 'https://via.placeholder.com/150/e0e0e0/000000?Text=Diapers',
      authorId: '아름엄마',
      content: '사이즈 미스로 남은 기저귀입니다. 뜯지 않은 새 제품이고, 40개 정도 남았습니다. 착불 택배로 보내드려요.',
      likes: 15,
      views: 250,
      postDate: '2025년 05월 15일',
    ),
    SharingItem(
      name: '[나눔] 아기띠 (에르고 베이비)',
      details: '직거래, 경기 고양시',
      imageUrl: null,
      authorId: '나눔천사',
      content: '출산 선물로 받았으나 다른 아기띠가 있어서 사용하지 않은 새 제품입니다. 깨끗하게 보관되어 있습니다.',
      likes: 8,
      views: 90,
      postDate: '2025년 05월 12일',
    ),
    SharingItem(
      name: '[나눔] 유아용 장난감 세트',
      details: '택배 가능',
      imageUrl: 'https://via.placeholder.com/150/d0d0d0/000000?Text=Toys',
      authorId: '장난감부자',
      content: '사용감 있지만 상태 좋은 유아용 장난감 세트입니다. 아이들이 좋아할 만한 다양한 종류가 있어요.',
      likes: 5,
      views: 70,
      postDate: '2025년 05월 10일',
    ),
  ];

  String selectedCategory = '나눔';

  void _handleCategoryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedCategory = newValue;
      });
      // TODO: 선택된 카테고리에 따라 아이템 필터링 또는 API 호출 등의 로직 추가
      print('선택된 카테고리: $selectedCategory');
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