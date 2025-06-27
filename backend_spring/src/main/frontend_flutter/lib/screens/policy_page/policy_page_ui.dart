import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import '../../pages/policy_page/policy_detail_page.dart';

// 정책 페이지 UI 전체
class PolicyPageUI extends StatelessWidget {
  final String dropdownValue;
  final void Function(String) onDropdownChanged;
  final TextEditingController searchController;
  final int currentPage;
  final void Function(int) onPageChanged;

  const PolicyPageUI({
    Key? key,
    required this.dropdownValue,
    required this.onDropdownChanged,
    required this.searchController,
    required this.currentPage,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      children: [
        // 드롭다운 + 검색창
        Padding(
          padding: const EdgeInsets.only(top: 18.0, bottom: 18.0),
          child: Row(
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                // 드롭다운
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    dropdownColor: AppTheme.primaryPurple,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    borderRadius: BorderRadius.circular(12),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onDropdownChanged(newValue);
                      }
                    },
                    items: <String>['최신순', '인기순', '오래된순']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontFamily: 'jua')),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 1),
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.textPurple),
                onPressed: () {
                  debugPrint('검색어: ${searchController.text}');
                },
              ),
            ],
          ),
        ),

        // 정책 카드 목록
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return PolicyCard(
              title: index == 0 ? '임신‧사전관리 지원사업' : '정책 제목 예시 $index',
              content: index == 0
                  ? '대상: 임신을 희망하는 만 20세~44세 여성\n내용: 건강검진, 상담 지원\n신청: 온라인 또는 방문'
                  : '정책 설명이 여기에 들어갑니다.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PolicyDetailPage(
                      title: '임신‧사전관리 지원사업',
                      imageUrl: '',
                      target: '임신을 희망하는 만 20세~44세 여성',
                      period: '2025.01.01 ~ 2025.12.31',
                      content: '건강검진, 상담 지원 등 제공',
                      method: '온라인 신청 또는 보건소 방문',
                      link: 'https://www.example.com',
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // 페이지네이션
        Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              if (index == 5) return const Text(' >');
              final pageNum = index + 1;
              final isSelected = pageNum == currentPage;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onPageChanged(pageNum),
                  child: Text(
                    '$pageNum',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryPurple : Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// 정책 카드 위젯
class PolicyCard extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onPressed;

  const PolicyCard({
    Key? key,
    required this.title,
    required this.content,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell( // 카드 전체 터치 가능하게 만듦
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightPink,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Text(content, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: onPressed, // 버튼에서도 동일하게 이동
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 36),
                ),
                child: const Text('신청하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
