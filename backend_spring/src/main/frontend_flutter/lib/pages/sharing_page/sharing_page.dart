import 'package:flutter/material.dart';
import '../../models/sharing_page/sharing_response.dart';
import '../../models/sharing_page/sharing_api_services.dart';
import '../../screens/sharing_page/sharing_page_ui.dart';
import 'write_sharing_page.dart';

class SharingPage extends StatefulWidget {
  final String? token;
  const SharingPage({Key? key, this.token}) : super(key: key);

  @override
  State<SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  String _selectedCategory = '나눔';
  late Future<List<SharingResponse>> _futureShares;

  @override
  void initState() {
    super.initState();
    print('[SharingPage] widget.token: ${widget.token}'); // <- 여기서 로그로 확인!
    _fetchShares();
  }

  void _fetchShares() {
    _futureShares = SharingApiServices.fetchSharingList(token: widget.token);
  }

  void _navigateToWritePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteSharingPage(token: widget.token),
      ),
    );
    if (result == true) {
      setState(() {
        _fetchShares();
      });
    }
  }

  void _handleFavoriteTap(int id) async {
    if (widget.token == null) return;
    await SharingApiServices.likeSharing(id, widget.token!);
    setState(() {
      _fetchShares();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharingAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SharingCategoryDropdown(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                  // 카테고리별 필터링 추가 원하면 여기에 적용 (현재는 전체 불러옴)
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SharingResponse>>(
              future: _futureShares,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('불러오기 실패: ${snapshot.error}'));
                }
                final shares = snapshot.data ?? [];
                if (shares.isEmpty) {
                  return const Center(child: Text('등록된 나눔/품앗이 글이 없습니다.'));
                }
                return ListView.builder(
                  itemCount: shares.length,
                  itemBuilder: (context, idx) {
                    final item = shares[idx];
                    return SharingListItem(
                      item: item,
                      onTap: () {}, // 상세페이지 이동 X
                      onFavoriteTap: () => _handleFavoriteTap(item.id),
                    );
                  },
                );
              },
            ),
          ),
          SharingActionButtons(
            onRequestTap: () {
              // 요청 기능 필요시 구현
            },
            onWriteTap: _navigateToWritePage,
          ),
        ],
      ),
    );
  }
}
