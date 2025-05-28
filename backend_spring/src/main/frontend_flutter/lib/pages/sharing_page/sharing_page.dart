import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_detail_page.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/pages/sharing_page/write_sharing_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        title: const Text('나눔 품앗이', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('함께함', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      dropdownColor: AppTheme.primaryPurple,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      items: ['나눔', '품앗이'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Jua'),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sharingItems.length,
              itemBuilder: (context, index) {
                final item = _sharingItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SharingDetailPage(item: item)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.imageUrl != null
                                  ? Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFFf9d9e7),
                                    child: const Center(
                                      child: Text('이미지 없음', style: TextStyle(color: Colors.grey)),
                                    ),
                                  );
                                },
                              )
                                  : Container(
                                color: const Color(0xFFf9d9e7),
                                child: const Center(
                                  child: Text('제품 이미지', style: TextStyle(color: Colors.grey)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(item.details, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border, color: AppTheme.primaryPurple),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('나눔 요청하기', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WriteSharingPostPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('나눔 글 작성', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
