import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/post/post_response.dart';
import 'package:frontend_flutter/models/post/post_api_services.dart';
import 'package:frontend_flutter/pages/community/create_post_page.dart';
import 'package:frontend_flutter/pages/community/post_detail_page.dart';

class CommunityAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommunityAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }
}

class CommunitySearchBar extends StatefulWidget {
  final Function(String type, String keyword) onSearch;

  const CommunitySearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  _CommunitySearchBarState createState() => _CommunitySearchBarState();
}

class _CommunitySearchBarState extends State<CommunitySearchBar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'title';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
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
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String value) {
                    setState(() {
                      _searchType = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'title',
                      child: Text('제목'),
                    ),
                    const PopupMenuItem(
                      value: 'content',
                      child: Text('내용'),
                    ),
                    const PopupMenuItem(
                      value: 'author',
                      child: Text('작성자'),
                    ),
                    const PopupMenuItem(
                      value: 'address',
                      child: Text('주소'),
                    ),
                  ],
                ),
              ),
              style: const TextStyle(color: AppTheme.textPurple),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              widget.onSearch(_searchType, _searchController.text);
            },
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
    );
  }
}

class CommunityCategoryButtons extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CommunityCategoryButtons({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  Widget _buildCategoryButton(String text) {
    bool isSelected = (selectedCategory == text);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          onCategorySelected(text);
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }
}

class PostList extends StatelessWidget {
  final Future<List<PostResponse>> futurePosts;

  const PostList({Key? key, required this.futurePosts}) : super(key: key);

  Widget _buildPostItem({required BuildContext context, required PostResponse post}) {
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
            post.imageUrl.isNotEmpty
                ? Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Image.network(
                post.imageUrl,
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
                      Icon(Icons.person, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        post.author,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      // ★ 주소 한줄 추가!
                      if (post.addressCity.isNotEmpty ||
                          post.addressDistrict.isNotEmpty ||
                          post.addressDong.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.place, size: 16, color: Colors.pink.shade200),
                            const SizedBox(width: 2),
                            Text(
                              "${post.addressCity} ${post.addressDistrict} ${post.addressDong}".trim(),
                              style: TextStyle(color: Colors.pink.shade300, fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      Icon(Icons.comment, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.thumb_up, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('${post.likeCount}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostResponse>>(
      future: futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('PostList FutureBuilder Error: ${snapshot.error}');
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
              return _buildPostItem(context: context, post: post);
            },
          );
        } else {
          return const Center(child: Text('데이터가 없습니다.'));
        }
      },
    );
  }
}

class CreatePostFab extends StatelessWidget {
  final String loggedInUserId;
  final VoidCallback onPostCreated;

  const CreatePostFab({
    Key? key,
    required this.loggedInUserId,
    required this.onPostCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final bool? postCreated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePostPage(isEdit: false),
          ),
        );

        if (postCreated == true) {
          onPostCreated();
        }
      },
      child: const Icon(Icons.edit),
      backgroundColor: AppTheme.primaryPurple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    );
  }
}
