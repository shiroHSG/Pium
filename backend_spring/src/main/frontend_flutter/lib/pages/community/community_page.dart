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
  String _loggedInUserId = ''; // 로그인된 사용자 ID를 저장할 변수

  @override
  void initState() {
    super.initState();
    _loadLoggedInUserId(); // initState에서 사용자 ID를 비동기적으로 로드
    _fetchPosts();
  }

  // SharedPreferences에서 로그인된 사용자 ID를 비동기적으로 로드하는 함수
  Future<void> _loadLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('memberId');
    if (id != null) {
      setState(() {
        _loggedInUserId = id.toString(); // 문자열로 변환
      });
      print("로드된 사용자 ID: $_loggedInUserId");
    } else {
      print("로그인된 사용자 ID를 찾을 수 없습니다. (아마 로그인 전이거나, 저장된 ID가 없음)");
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

  // 게시글 작성 후 목록을 새로고침하는 콜백 함수
  void _onPostCreated() {
    _fetchPosts(); // 게시글이 생성되면 다시 API를 호출하여 목록을 업데이트
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
        loggedInUserId: _loggedInUserId, // 로드된 사용자 ID를 CreatePostFab에 전달
        onPostCreated: _onPostCreated, // 게시글 생성 후 새로고침 콜백 전달
      ),
    );
  }
}