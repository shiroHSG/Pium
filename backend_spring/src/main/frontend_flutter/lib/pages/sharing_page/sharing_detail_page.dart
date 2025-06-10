import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:frontend_flutter/models/sharing_item.dart';

class SharingDetailPage extends StatelessWidget {
  final SharingItem item;

  const SharingDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 30, thickness: 1, color: Colors.grey),
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.imageUrl != null
                        ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFf9d9e7),
                          child: const Center(
                            child: Text('이미지 로드 실패', style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      },
                    )
                        : Container(
                      color: AppTheme.lightPink,
                      child: const Center(
                        child: Text(
                          '제품 이미지',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 13.0),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.authorId,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '작성일 : ${item.postDate}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.favorite_border, color: AppTheme.primaryPurple, size: 20),
                              onPressed: () {
                                print('하트 버튼이 클릭되었습니다!');
                              },
                            ),
                            Text('${item.likes}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye_outlined, color: Colors.grey, size: 20),
                            const SizedBox(width: 4),
                            Text('${item.views}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    item.content,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 채팅하기 기능 구현
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    '채팅하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}