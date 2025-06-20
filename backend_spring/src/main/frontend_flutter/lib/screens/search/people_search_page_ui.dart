import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/people_search/member_api.dart';

class PeopleSearchInput extends StatelessWidget {
  final TextEditingController searchController;
  final Function(List<Map<String, String>>) onSearchResults;

  const PeopleSearchInput({
    Key? key,
    required this.searchController,
    required this.onSearchResults,
  }) : super(key: key);

  Future<void> _performSearch() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      onSearchResults([]);
      return;
    }

    try {
      final results = await MemberApi.searchMembers(query);
      onSearchResults(results.map((member) => {
        'nickname': member.nickname,
        'location': member.address,
        'profileImageUrl': member.profileImageUrl ?? '',
      }).toList());
    } catch (e) {
      print('검색 실패: $e');
      onSearchResults([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: '사람 찾기',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                  const BorderSide(color: AppTheme.lightPink, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                  const BorderSide(color: AppTheme.primaryPurple, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              icon: Icon(Icons.search, color: Colors.grey[700]),
              onPressed: _performSearch,
            ),
          ),
        ],
      ),
    );
  }
}

class PeopleSearchResultItem extends StatelessWidget {
  final Map<String, dynamic> user;
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
          color: Colors.white,
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
            // 프로필 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lightPink,
                image: user['profileImageUrl'] != null &&
                    user['profileImageUrl'].toString().isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(user['profileImageUrl']),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: user['profileImageUrl'] == null ||
                  user['profileImageUrl'].toString().isEmpty
                  ? const Center(
                child: Text(
                  '프로필\n사진',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textPurple,
                    fontSize: 12,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 16),
            // 닉네임 + 주소
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['nickname'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  Text(
                    user['location'] ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // 버튼 2개
            ElevatedButton(
              onPressed: onMateButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
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
                backgroundColor: AppTheme.primaryPurple,
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
