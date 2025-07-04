import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/screens/policy_page/policy_page_ui.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({Key? key}) : super(key: key);

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  String _dropdownValue = '최신순';
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();

  // 드롭다운 변경 시 호출
  void _onDropdownChanged(String value) {
    setState(() {
      _dropdownValue = value;
      _currentPage = 1; // 정렬 변경 시 1페이지로 리셋
    });
  }

  // 페이지네이션 변경 시 호출
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
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
        backgroundColor: AppTheme.primaryPurple,
        elevation: 0,
        title: const Text(
          '정보 제공',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // 알림 페이지 이동 등
            },
            color: Colors.white,
          ),
        ],
      ),
      body: PolicyPageUI(
        dropdownValue: _dropdownValue,
        onDropdownChanged: _onDropdownChanged,
        searchController: _searchController,
        currentPage: _currentPage,
        onPageChanged: _onPageChanged,
      ),
    );
  }
}
