import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/sharing_page/sharing_detail_page.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/pages/sharing_page/write_sharing_page.dart';
import 'package:frontend_flutter/screens/sharing_page/sharing_page_ui.dart';
import '../../models/sharing_page/sharing_api_service.dart';

class SharingPage extends StatefulWidget {
  const SharingPage({Key? key}) : super(key: key);

  @override
  State<SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  List<SharingItem> _sharingItems = [];
  String selectedCategory = '전체';
  String _searchKeyword = '';
  bool _isSearching = false;

  List<SharingItem> get filteredItems {
    // 카테고리 필터는 서버에서 이미 반영, 프론트에서는 전체 사용
    return _sharingItems;
  }

  @override
  void initState() {
    super.initState();
    _loadSharingItems();
  }

  Future<void> _loadSharingItems() async {
    try {
      final items = await SharingApiService.fetchAllShares();
      setState(() {
        _sharingItems = items;
      });
    } catch (e) {
      print('나눔글 불러오기 실패: $e');
    }
  }

  Future<void> _searchShares(String keyword, String category) async {
    print('🔍 [DEBUG] _searchShares called with: $keyword, category: $category');
    if (keyword.trim().isEmpty && (category == '전체')) {
      await _loadSharingItems();
      return;
    }
    setState(() => _isSearching = true);
    try {
      print('🔍 [DEBUG] Calling searchShares API with: $keyword / $category');
      final items = await SharingApiService.searchShares(keyword.trim(), category);
      print('🔍 [DEBUG] API returned ${items.length} items');
      setState(() {
        _sharingItems = items;
      });
    } catch (e) {
      print('검색 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('검색 실패')));
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _navigateToDetail(SharingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SharingDetailPage(item: item)),
    );
  }

  void _navigateToWritePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WriteSharingPostPage()),
    );
  }

  void _handleFavorite(SharingItem item) {
    print('${item.name} 찜하기');
  }

  void _handleCategoryChanged(String? newValue) async {
    if (newValue != null) {
      setState(() {
        selectedCategory = newValue;
      });
      // 카테고리 변경 시 바로 검색 적용 (선택: 원하면 주석 해제)
      // await _searchShares(_searchKeyword, newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SharingPage build!');
    return Scaffold(
      appBar: const SharingAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                // 🔍 검색창 + 검색 버튼
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '제목, 작성자, 주소로 검색',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchKeyword.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchKeyword = '';
                                _isSearching = false;
                              });
                              _loadSharingItems();
                            },
                          )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          print('🔍 [DEBUG] onChanged: $value');
                          setState(() {
                            _searchKeyword = value;
                          });
                        },
                        onSubmitted: (value) async {
                          print('🔍 [DEBUG] onSubmitted called with: $value');
                          await _searchShares(value, selectedCategory);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ⭐️ 검색 버튼
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        print('🔍 [DEBUG] 검색 버튼 클릭: $_searchKeyword / $selectedCategory');
                        await _searchShares(_searchKeyword, selectedCategory);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('함께함', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SharingCategoryDropdown(
                      selectedCategory: selectedCategory,
                      onCategoryChanged: _handleCategoryChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _sharingItems.isEmpty
                ? Center(
              child: Text(
                _searchKeyword.isNotEmpty ? '검색 결과 없음' : '나눔글이 없습니다.',
                style: const TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return SharingListItem(
                  item: item,
                  onTap: () => _navigateToDetail(item),
                  onFavoriteTap: () => _handleFavorite(item),
                );
              },
            ),
          ),
          SharingActionButtons(
            onWriteTap: () {
              print('글 작성 버튼 클릭!');
              _navigateToWritePost();
            },
          ),
        ],
      ),
    );
  }
}
