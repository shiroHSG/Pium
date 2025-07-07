// lib/pages/search/people_search_page.dart
import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/people_search/member_api.dart';
import 'package:frontend_flutter/screens/search/people_search_page_ui.dart';

import '../../models/chat/chat_service.dart';
import '../../models/mate/mate_api.dart';
import '../chat/chat_room_message_page.dart';

class PeopleSearchPage extends StatefulWidget {
  const PeopleSearchPage({Key? key}) : super(key: key);

  @override
  State<PeopleSearchPage> createState() => _PeopleSearchPageState();
}

class _PeopleSearchPageState extends State<PeopleSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void _updateSearchResults(List<Map<String, dynamic>> results) {
    setState(() {
      _searchResults = results;
    });
  }

  void _handleMateButton(int receiverId) async {
    await MateApi.requestMate(receiverId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("메이트 요청을 보냈습니다")),
    );
  }

  void _handleMessageButton(int receiverId) async {
    try {
      final chatRoom = await createOrGetDirectChatRoom(receiverId);
      final fullDetail = await fetchChatRoomDetail(chatRoom.chatRoomId);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomPage(chatRoom: fullDetail),
        ),
      );
    } catch (e) {
      print('❌ 채팅방 생성 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅방을 생성하는 데 실패했습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메이트 찾기'),
      ),
      body: Column(
        children: [
          PeopleSearchInput(
            searchController: _searchController,
            onSearchResults: _updateSearchResults, // <- 오류 발생
          ),
          Expanded(
            child: _searchController.text.isEmpty
                ? const Center(child: Text('주소지 또는 사용자 별명을 검색하여 주십시오.'))
                : _searchResults.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return PeopleSearchResultItem(
                  user: user,
                  onMateButtonPressed: () => _handleMateButton(user['memberId']!),
                  onMessageButtonPressed: () => _handleMessageButton(user['memberId']),

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
