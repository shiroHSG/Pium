import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class PeopleSearchInput extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchPressed;

  const PeopleSearchInput({
    Key? key,
    required this.searchController,
    required this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '사람 찾기',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: AppTheme.lightPink, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightPink,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.grey[700]), // 검색 아이콘 색상
              onPressed: onSearchPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class PeopleSearchResultItem extends StatelessWidget {
  final Map<String, String> user;
  final VoidCallback onMateButtonPressed;
  final VoidCallback onMessageButtonPressed;

  const PeopleSearchResultItem({
    Key? key,
    required this.user,
    required this.onMateButtonPressed,
    required this.onMessageButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white, // 카드 배경색
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.lightPink, // 프로필 사진 배경색
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '프로필\n사진',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textPurple,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['nickname']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  Text(
                    user['location']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onMateButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple, // 메이트 맺기 버튼 배경색
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('메이트 맺기', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onMessageButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple, // 메시지 보내기 버튼 배경색
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('메세지 보내기', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}