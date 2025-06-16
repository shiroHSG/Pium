import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class PolicyDetailPageUI extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String target;
  final String period;
  final String content;
  final String method;
  final String link;

  const PolicyDetailPageUI({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.target,
    required this.period,
    required this.content,
    required this.method,
    required this.link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 커스텀 헤더
            Container(
              padding: const EdgeInsets.only(top: 30, left: 8, right: 8, bottom: 8),
              color: AppTheme.primaryPurple,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // ✅ 본문
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 (왼쪽 정렬 + 살짝 들여쓰기)
                  Padding(
                    padding: const EdgeInsets.only(left: 23.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 이미지 (가운데 정렬)
                  Center(
                    child: Container(
                      height: 180,
                      width: 320,
                      decoration: BoxDecoration(
                        color: AppTheme.lightPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '정책 홍보 이미지',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 상세 정보 박스
                  Center(
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('지원 대상 : $target',
                              style: const TextStyle(fontSize: 14, color: AppTheme.textPurple)),
                          const SizedBox(height: 8),
                          Text('신청 기간 : $period',
                              style: const TextStyle(fontSize: 14, color: AppTheme.textPurple)),
                          const SizedBox(height: 8),
                          Text('내용 : $content',
                              style: const TextStyle(fontSize: 14, color: AppTheme.textPurple)),
                          const SizedBox(height: 8),
                          Text('신청 방법 : $method',
                              style: const TextStyle(fontSize: 14, color: AppTheme.textPurple)),
                          const SizedBox(height: 8),
                          Text('신청 링크 : $link',
                              style: const TextStyle(fontSize: 14, color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 신청하기 버튼
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: 신청 링크 연결
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('신청하기'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
