import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/community/create_post_page.dart';
import 'package:frontend_flutter/pages/community/post_detail_page.dart';
import 'package:frontend_flutter/models/post_response.dart';
import 'package:frontend_flutter/services/post_api_services.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _selectedCategory = '전체';
  late Future<List<PostResponse>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  void _fetchPosts() {
    setState(() {
      _futurePosts = PostApiService.fetchPosts(_selectedCategory == '전체' ? '' : _selectedCategory);
    });
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
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
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PostResponse>>(
              future: _futurePosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('게시글을 불러오는데 실패했습니다: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final posts = snapshot.data!;
                  if (posts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          '해당 카테고리의 게시글이 없습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _buildPostItem(post: post);
                    },
                  );
                } else {
                  return const Center(child: Text('데이터가 없습니다.'));
                }
              },
            ),
          ),
        ],
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
            _fetchPosts();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryPurple : Colors.white,
          foregroundColor: isSelected ? Colors.white : AppTheme.textPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppTheme.primaryPurple),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size.zero,
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildPostItem({required PostResponse post}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(
              post: post as dynamic,
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
            post.postImg != null && post.postImg!.isNotEmpty
                ? Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Image.network(
                '${PostApiService.baseUrl}/${post.postImg!}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
                },
              ),
            )
                : Container(
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
                      Text('0', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.thumb_up, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('0', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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