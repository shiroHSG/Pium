import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/community/create_post_page.dart';
import 'package:frontend_flutter/pages/community/post_detail_page.dart';
import 'package:frontend_flutter/models/post_detail.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _selectedCategory = '전체';

  // 모든 게시글 데이터를 저장하는 리스트
  final List<PostDetail> _allPosts = [
    PostDetail(
      title: '첫 게시글 제목',
      content: '이것은 첫 번째 게시글의 내용입니다. 상세 페이지에서 더 많은 내용을 볼 수 있습니다.',
      authorId: '사용자123',
      category: '자유',
      date: '2025년 05월 20일',
      likes: 10,
      views: 120,
      comments: [
        Comment(author: '댓글러1', text: '정말 좋은 글이네요!'),
        Comment(author: '댓글러2', text: '공감합니다.'),
      ],
    ),
    PostDetail(
      title: '꿀팁 공유합니다!',
      content: '육아에 도움이 되는 꿀팁을 공유합니다. 자세한 내용은 클릭해주세요. 실제 꿀팁은 매우 길 수 있습니다.',
      authorId: '육아마스터',
      category: '팁',
      date: '2025년 05월 19일',
      likes: 25,
      views: 300,
      comments: [
        Comment(author: '궁금맘', text: '어떤 팁인지 궁금해요!'),
        Comment(author: '초보아빠', text: '덕분에 많은 도움이 됐어요.'),
      ],
    ),
    PostDetail(
      title: '궁금한 점이 있어요!',
      content: '초보 엄마입니다. 이것저것 궁금한 점이 많아요. 특히 수유에 대한 질문이 많습니다.',
      authorId: '초보맘',
      category: '질문',
      date: '2025년 05월 18일',
      likes: 5,
      views: 80,
      comments: [
        Comment(author: '경험맘', text: '제가 아는 선에서 답변해드릴게요!'),
      ],
    ),
    PostDetail(
      title: '모임 같이 하실 분?',
      content: '육아 모임 만들어서 정보 공유하고 싶어요. 지역은 서울 강남구입니다.',
      authorId: '모임장',
      category: '모임',
      date: '2025년 05월 17일',
      likes: 8,
      views: 150,
      comments: [],
    ),
    PostDetail(
      title: '자유롭게 이야기해요',
      content: '일상적인 이야기 나누고 싶어요. 편하게 댓글 달아주세요. 오늘은 날씨가 좋네요.',
      authorId: '자유인',
      category: '자유',
      date: '2025년 05월 16일',
      likes: 7,
      views: 90,
      comments: [
        Comment(author: '지나가던', text: '네 안녕하세요!'),
      ],
    ),
  ];

  // 현재 선택된 카테고리에 따라 필터링된 게시글 리스트를 반환하는 Getter
  List<PostDetail> get _filteredPosts {
    if (_selectedCategory == '전체') {
      return _allPosts;
    } else {
      return _allPosts.where((post) => post.category == _selectedCategory).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        title: const Text(
          '커뮤니티',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
            color: Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '검색어를 입력해주세요',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      ),
                      style: const TextStyle(color: AppTheme.textPurple),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      minimumSize: const Size(50, 48),
                    ),
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryButton('전체'),
                    _buildCategoryButton('자유'),
                    _buildCategoryButton('팁'),
                    _buildCategoryButton('질문'),
                    _buildCategoryButton('모임'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 필터링된 게시글 목록을 표시
              if (_filteredPosts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      '해당 카테고리의 게시글이 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._filteredPosts.map((post) => _buildPostItem(post: post)).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
        },
        child: const Icon(Icons.edit),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text) {
    bool isSelected = (_selectedCategory == text);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = text;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryPurple : Colors.white,
          foregroundColor: isSelected ? Colors.white : AppTheme.textPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: AppTheme.primaryPurple),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size.zero,
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildPostItem({required PostDetail post}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(
              post: post,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.only(right: 12),
              child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPurple),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.content.length > 50 ? '${post.content.substring(0, 50)}...' : post.content,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.comment, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(post.comments.length.toString(), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.thumb_up, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(post.likes.toString(), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}