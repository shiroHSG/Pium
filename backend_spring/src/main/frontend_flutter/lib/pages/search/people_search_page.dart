// lib/pages/search/people_search_page.dart
import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/screens/search/people_search_page_ui.dart';

class PeopleSearchPage extends StatefulWidget {
  const PeopleSearchPage({Key? key}) : super(key: key);

  @override
  State<PeopleSearchPage> createState() => _PeopleSearchPageState();
}

class _PeopleSearchPageState extends State<PeopleSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // 더미 데이터 (실제로는 API에서 받아올 데이터)
  final List<Map<String, String>> _users = [
    {
      'nickname': 'Nickname1',
      'location': '서울특별시 강동구',
    },
    {
      'nickname': 'Nickname2',
      'location': '서울특별시 송파구',
    },
    {
      'nickname': 'Nickname3',
      'location': '경기도 성남시',
    },
    {
      'nickname': 'Nickname4',
      'location': '인천광역시',
    },
    {
      'nickname': 'Nickname5',
      'location': '대전광역시',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    // TODO: 검색 기능 구현
    print('검색어: ${_searchController.text}');
  }

  void _handleMateButton(String nickname) {
    print('메이트 맺기 버튼 클릭: $nickname');
    // TODO: 메이트 맺기 로직
  }

  void _handleMessageButton(String nickname) {


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메이트 찾기'),
        backgroundColor: AppTheme.primaryPurple,
      ),
      body: Column(
        children: [
          PeopleSearchInput(
            searchController: _searchController,
            onSearchPressed: _handleSearch,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return PeopleSearchResultItem(
                  user: user,
                  onMateButtonPressed: () => _handleMateButton(user['nickname']!),
                  onMessageButtonPressed: () => _handleMessageButton(user['nickname']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}