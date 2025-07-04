import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/post/post_response.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_flutter/screens/community/community_page_ui.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _selectedCategory = '전체';
  late Future<List<PostResponse>> _futurePosts;
  String _searchKeyword = '';
  String _searchType = '';
  String _loggedInUserId = '';

  @override
  void initState() {
    super.initState();
    _loadLoggedInUserId();
    _fetchPosts();
  }

  Future<void> _loadLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('loggedInUserId');
    if (userId != null) {
      setState(() {
        _loggedInUserId = userId;
      });
      print("로드된 사용자 ID: $_loggedInUserId");
    } else {
      print("로그인된 사용자 ID를 찾을 수 없습니다.");
      // 필요시 로그인 페이지로 이동 처리 등 구현 가능
    }
  }

  void _fetchPosts() {
    setState(() {
      _futurePosts = PostApiService.fetchPosts(
        _selectedCategory == '전체' ? null : _selectedCategory,
        type: _searchType.isNotEmpty ? _searchType : null,
        keyword: _searchKeyword.isNotEmpty ? _searchKeyword : null,
      );
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _fetchPosts();
    });
  }

  void _onSearch(String type, String keyword) {
    setState(() {
      _searchType = type;
      _searchKeyword = keyword;
      _fetchPosts();
    });
  }

  void _onPostCreated() {
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunitySearchBar(onSearch: _onSearch),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CommunityCategoryButtons(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PostList(futurePosts: _futurePosts),
          ),
        ],
      ),
      floatingActionButton: CreatePostFab(
        loggedInUserId: _loggedInUserId,
        onPostCreated: _onPostCreated,
      ),
    );
  }
}
